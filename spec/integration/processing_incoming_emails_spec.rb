require 'spec_helper'

describe "processing incoming emails" do

  before do
    VerifyDmarc.stub(:call).and_return(true)
  end

  let :params do
    create_incoming_email_params(
      subject:       subject,
      message_id:    message_id,

      from:          from,
      envelope_from: envelope_from,
      sender:        sender,

      recipient:     recipient,
      to:            to,
      cc:            cc,

      content_type:  content_type,
      date:          date,

      in_reply_to:   in_reply_to,
      references:    references,

      body_html:     body_html,
      body_plain:    body_plain,
      stripped_html: stripped_html,
      stripped_text: stripped_text,
      attachments:   attachments,

      thread_index:  thread_index,
      thread_topic:  thread_topic,
    )
  end


  def validate! result
    post emails_url, params
    expect(response).to be_ok

    incoming_email = threadable.incoming_emails.latest

    # before being processed
    expect( params['recipient'] ).to include incoming_email.params['recipient']

    expect( incoming_email.params['timestamp']        ).to eq params['timestamp']
    expect( incoming_email.params['token']            ).to eq params['token']
    expect( incoming_email.params['signature']        ).to eq params['signature']
    expect( incoming_email.params['sender']           ).to eq params['sender']
    expect( incoming_email.params['Sender']           ).to eq params['Sender']
    expect( incoming_email.params['subject']          ).to eq params['subject']
    expect( incoming_email.params['Subject']          ).to eq params['Subject']
    expect( incoming_email.params['from']             ).to eq params['from']
    expect( incoming_email.params['From']             ).to eq params['From']
    expect( incoming_email.params['X-Envelope-From']  ).to eq params['X-Envelope-From']
    expect( incoming_email.params['In-Reply-To']      ).to eq params['In-Reply-To']
    expect( incoming_email.params['References']       ).to eq params['References']
    expect( incoming_email.params['Date']             ).to eq params['Date']
    expect( incoming_email.params['Message-Id']       ).to eq params['Message-Id']
    expect( incoming_email.params['To']               ).to eq params['To']
    expect( incoming_email.params['Cc']               ).to eq params['Cc']
    expect( incoming_email.params['Content-Type']     ).to eq params['Content-Type']
    expect( incoming_email.params['message-headers']  ).to eq params['message-headers']
    expect( incoming_email.params['body-plain']       ).to eq params['body-plain']
    expect( incoming_email.params['body-html']        ).to eq params['body-html']
    expect( incoming_email.params['stripped-html']    ).to eq params['stripped-html']
    expect( incoming_email.params['stripped-text']    ).to eq params['stripped-text']
    expect( incoming_email.params['attachment-count'] ).to eq attachments.count.to_s
    attachments.size.times do |n|
      expect( incoming_email.params["attachment-#{n+1}"] ).to be_present
    end

    expect( recipient ).to include incoming_email.recipient

    expect( incoming_email.subject                ).to eq(subject)
    expect( incoming_email.message_id             ).to eq(message_id)
    expect( incoming_email.from                   ).to eq(from)
    expect( incoming_email.envelope_from          ).to eq(envelope_from)
    expect( incoming_email.sender                 ).to eq(sender)
    expect( incoming_email.to                     ).to eq(to)
    expect( incoming_email.cc                     ).to eq(cc)
    expect( incoming_email.content_type           ).to eq(content_type)
    expect( incoming_email.date                   ).to eq(date)
    expect( incoming_email.in_reply_to            ).to eq(in_reply_to)
    expect( incoming_email.references             ).to eq(references)
    expect( incoming_email.message_headers.to_set ).to eq Set[
      ["X-Envelope-From", envelope_from],
      ["Sender",          sender],
      ["In-Reply-To",     in_reply_to],
      ["References",      references],
      ["From",            from],
      ["Date",            date.rfc2822],
      ["Message-Id",      message_id],
      ["Subject",         subject],
      ["To",              to],
      ["Cc",              cc],
      ["Content-Type",    content_type],
      ["Thread-Index",    thread_index],
      ["Thread-Topic",    thread_topic],
    ]
    expect( incoming_email.body_html      ).to eq(body_html)
    expect( incoming_email.body_plain     ).to eq(body_plain)
    expect( incoming_email.stripped_html  ).to eq(stripped_html)
    expect( incoming_email.stripped_plain ).to eq(stripped_text)

    # process incoming email
    drain_background_jobs!
    incoming_email = threadable.incoming_emails.find_by_id(incoming_email.id) # reload

    # after being processed
    case result
    when :bounced
      expect( incoming_email ).to     be_bounced
      expect( incoming_email ).to_not be_held
      expect( incoming_email ).to_not be_delivered
      expect( incoming_email ).to_not be_dropped
    when :held
      expect( incoming_email ).to_not be_bounced
      expect( incoming_email ).to     be_held
      expect( incoming_email ).to_not be_delivered
      expect( incoming_email ).to_not be_dropped
    when :dropped
      expect( incoming_email ).to_not be_bounced
      expect( incoming_email ).to_not be_held
      expect( incoming_email ).to_not be_delivered
      expect( incoming_email ).to     be_dropped
    when :delivered, :duplicate
      expect( incoming_email ).to_not be_bounced
      expect( incoming_email ).to_not be_held
      expect( incoming_email ).to     be_delivered
      expect( incoming_email ).to_not be_dropped
    else
      raise "expect result to :bounced, :held, :delivered, :dropped or :duplicate. got #{result.inspect}"
    end

    expect( incoming_email.organization   ).to eq expected_organization
    expect( incoming_email.parent_message ).to eq expected_parent_message
    expect( incoming_email.conversation   ).to eq expected_conversation
    expect( incoming_email.creator        ).to eq expected_creator

    if result == :bounced || result == :held || result == :dropped
      expect( incoming_email.message                    ).to be_nil
      expect( incoming_email.params['attachment-count'] ).to eq attachments.count.to_s
      expect( incoming_email.params['attachment-1']     ).to be_present
      expect( incoming_email.params['attachment-2']     ).to be_present
      expect( incoming_email.params['attachment-3']     ).to be_present

      if result == :held
        if expect_message_held_notice_sent
          # held mail gets sent an auto-response
          expect(sent_emails.size).to eq 1
          held_notice = sent_emails.first
          expect( held_notice.smtp_envelope_from ).to eq "no-reply-auto@#{threadable.email_host}"
          expect( held_notice.smtp_envelope_to   ).to eq [envelope_from.gsub(/[<>]/, '')]
          expect( held_notice.to                 ).to eq [envelope_from.gsub(/[<>]/, '')]
          expect( held_notice.from               ).to eq ["support+message-held@#{threadable.email_host}"]
          expect( held_notice.subject            ).to eq "[message held] #{subject}"

          expect( held_notice.header['Reply-To'].to_s       ).to eq "Threadable message held <support+message-held@#{threadable.email_host}>"
          expect( held_notice.header['In-Reply-To'].to_s    ).to eq incoming_email.message_id
          expect( held_notice.header['References'].to_s     ).to eq incoming_email.message_id
          expect( held_notice.header['Auto-Submitted'].to_s ).to eq 'auto-replied'
        else
          expect(sent_emails.size).to eq 0
        end
      end

      return
    end

    # only validating delivered/duplicate messages beyond this point


    expect( incoming_email.message ).to be_present
    expect( incoming_email.conversation ).to be_present

    message      = threadable.messages.latest
    conversation = expected_organization.conversations.latest

    expect( incoming_email.message      ).to eq message
    expect( incoming_email.conversation ).to eq conversation
    expect( message.conversation        ).to eq conversation

    if expect_conversation_to_be_a_task
      expect( conversation ).to be_task
      if expect_task_to_be_done
        expect( conversation ).to be_done
      else
        expect( conversation ).to_not be_done
      end
    else
      expect( conversation ).to_not be_task
    end

    expect( incoming_email.params['attachment-count'] ).to be_nil
    expect( incoming_email.params['attachment-1']     ).to be_nil
    expect( incoming_email.params['attachment-2']     ).to be_nil
    expect( incoming_email.params['attachment-3']     ).to be_nil

    expect( message.organization        ).to eq expected_organization
    expect( message.conversation        ).to eq expected_conversation
    expect( message.message_id_header   ).to eq message_id
    expect( message.to_header           ).to eq to
    expect( message.cc_header           ).to eq cc
    expect( message.date_header         ).to eq date.rfc2822
    expect( message.references_header   ).to eq references
    expect( message.subject             ).to eq expected_message_subject
    expect( message.body_plain          ).to eq expected_message_body_plain
    expect( message.body_html           ).to eq expected_message_body_html
    expect( message.stripped_html       ).to eq expected_message_stripped_html
    expect( message.stripped_plain      ).to eq expected_message_stripped_text
    expect( message.thread_index_header ).to eq expected_message_thread_index
    expect( message.thread_topic_header ).to eq expected_message_thread_topic

    expect( message.conversation.groups.all.map(&:name) ).to match_array expected_groups

    incoming_email_attachments = incoming_email.attachments.all.map do |attachment|
      [attachment.filename, attachment.mimetype, attachment.content]
    end.to_set

    expect( sent_emails.map(&:smtp_envelope_to).flatten ).to match_array expected_email_recipients

    if result == :duplicate
      expect( incoming_email.params['attachment-count'] ).to be_nil
      expect( incoming_email.params['attachment-1']     ).to be_nil
      expect( incoming_email.params['attachment-2']     ).to be_nil
      expect( incoming_email.params['attachment-3']     ).to be_nil
      expect( incoming_email_attachments ).to be_empty
      return
    end

    # only validating delivered messages beyond this point

    expect(incoming_email_attachments).to eq posted_attachments
    if check_attachments
      expect( message.attachments.all.to_set ).to eq incoming_email.attachments.all.to_set
    end

    recipients = message.recipients.all.reject do |user|
      message.creator.same_user?(user) if message.creator
    end

    recipients.each do |recipient|
      expect(message.sent_to?(recipient)).to be_true
      expect(message.sent_email(recipient).relayed?).to be_true
    end

    recipient_email_addresses = recipients.map(&:email_address)
    expected_emails_count = recipient_email_addresses.length
    expect(sent_emails.count).to eq expected_emails_count


    sent_emails.each do |email|
      expect( email.from ).to eq(
        (message.creator && email.smtp_envelope_to.include?(message.creator.email_address) ) ?
        [recipient] : [ExtractEmailAddresses.call(from).first]
      )
      expect( email.message_id                      ).to eq message_id[1..-2]
      expect( email.header[:References].to_s        ).to eq references
      expect( email.date.in_time_zone.rfc2822       ).to eq date.rfc2822
      if expected_sent_email_to.is_a? Set
        expect( email.to.to_set                     ).to eq expected_sent_email_to
      else
        expect( email.to                            ).to eq expected_sent_email_to
      end
      expect( email.header[:Cc].to_s                   ).to eq expected_sent_email_cc
      expect( email.smtp_envelope_to.length            ).to eq 1
      expect( recipient_email_addresses                ).to include email.smtp_envelope_to.first
      expect( email.smtp_envelope_from                 ).to eq expected_sent_email_smtp_envelope_from
      expect( email.subject                            ).to eq expected_sent_email_subject
      expect( email.html_content                       ).to include expected_sent_email_body_html
      expect( email.text_content                       ).to include expected_sent_email_body_plain
      expect( email.header['Reply-To'].to_s            ).to eq expected_sent_email_reply_to
      expect( email.header['List-ID'].to_s             ).to eq expected_sent_email_list_id
      expect( email.header['List-Archive'].to_s        ).to eq expected_sent_email_list_archive
      expect( email.header['List-Unsubscribe'].to_s    ).to be_present
      expect( email.header['List-Post'].to_s           ).to eq expected_sent_email_list_post

      expected_mailgun_variables = {
        'organization' => expected_organization.slug,
        'recipient-id' => expected_organization.members.find_by_email_address(email.smtp_envelope_to.first).id,
      }.to_json

      expect( email.header['X-Mailgun-Variables'].to_s ).to eq expected_mailgun_variables

      content_ids = JSON.parse(params["content-id-map"])
      email.mail_message.attachments.each do |sent_attachment|
        expect( content_ids ).to have_key sent_attachment.content_id
      end
    end
  end


  let(:posted_attachments) do
    attachments.map do |attachment|
      [attachment.original_filename, attachment.content_type, File.read(attachment.path)]
    end.to_set
  end

  let(:check_attachments) { true }

  # default incoming email params

  let(:subject)      { 'OMG guys I love threadable!' }
  let(:message_id)   { '<CABQbZc9oj=-_0WwB2eZKq6xLwaM2-b_X2rdjuC5qt-NFi1gDHw@mail.gmail.com>' }

  let(:from)         { 'Yan Hzu <yan@ucsd.example.com>' }
  let(:envelope_from){ '<yan@ucsd.example.com>' }
  let(:sender)       { 'yan@ucsd.example.com' }

  let(:recipient)    { 'raceteam@127.0.0.1' }
  let(:to)           { 'UCSD Electric Racing <raceteam@127.0.0.1>' }
  let(:cc)           { '' }

  let(:content_type) { 'multipart/alternative; boundary="089e0158ba9ec5cbb704eb3fc74e"' }
  let(:date)         { Time.parse(14.days.ago.to_s).in_time_zone } # round off milliseconds

  let(:in_reply_to)  { '' }
  let(:references)   { '' }
  let(:thread_index) { '' }
  let(:thread_topic) { '' }

  let(:body_html){
    %(<p>I think we should build it out of fiberglass and duck tape.\n</p>\n)+
    %(<blockquote>)+
    %(I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
    %(make the body out of carbon or buy a giant boat and cut it up or whatever.)+
    %(</blockquote>)
  }
  let(:body_plain){
    %(I think we should build it out of fiberglass and duck tape.\n\n)+
    %(> I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
    %(> make the body out of carbon or buy a giant boat and cut it up or whatever.)
  }
  let(:stripped_html){
    %(<p>I think we should build it out of fiberglass and duck tape.\n</p>)
  }
  let(:stripped_text){
    %(I think we should build it out of fiberglass and duck tape.)
  }

  let :attachments do
    [
      RSpec::Support::Attachments.uploaded_file("some.gif", 'image/gif',  true),
      RSpec::Support::Attachments.uploaded_file("some.jpg", 'image/jpeg', true),
      RSpec::Support::Attachments.uploaded_file("some.txt", 'text/plain', false),
    ]
  end

  # default expected values for the default incoming email params above

  let(:expected_parent_message)                { nil }
  let(:expected_conversation)                  { expected_organization.conversations.latest }
  let(:expected_creator)                       { threadable.users.find_by_email_address('yan@ucsd.example.com') }
  let(:expected_organization)                  { threadable.organizations.find_by_slug!('raceteam') }
  let(:expected_conversation_subject)          { 'OMG guys I love threadable!' }
  let(:expected_message_subject)               { 'OMG guys I love threadable!' }
  let(:expected_message_body_html)             { body_html }
  let(:expected_message_body_plain)            { body_plain }
  let(:expected_message_stripped_html)         { stripped_html }
  let(:expected_message_stripped_text)         { stripped_text }
  let(:expected_message_thread_index)          { thread_index }
  let(:expected_message_thread_topic)          { thread_topic }
  let(:expect_conversation_to_be_a_task)       { false }
  let(:expect_task_to_be_done)                 { false }
  let(:expected_email_recipients)              { ["alice@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "nadya@ucsd.example.com", "bob@ucsd.example.com"] }
  let(:expected_sent_email_to)                 { ['raceteam@127.0.0.1'] }
  let(:expected_sent_email_cc)                 { '' }
  let(:expected_sent_email_subject)            { "#{expected_conversation.subject_tag} OMG guys I love threadable!" }
  let(:expected_sent_email_smtp_envelope_from) { 'raceteam@127.0.0.1' }
  let(:expected_sent_email_reply_to)           { 'UCSD Electric Racing <raceteam@127.0.0.1>' }
  let(:expected_sent_email_list_id)            { expected_conversation.list_id }
  let(:expected_sent_email_list_archive)       { "<#{conversations_url(expected_organization, 'my')}>" }
  let(:expected_sent_email_list_post)          { "<mailto:#{expected_conversation.list_post_email_address}>, <#{compose_conversation_url(expected_organization, 'my')}>" }
  let(:expected_sent_email_body_html)          { body_html }
  let(:expected_sent_email_body_plain)         { body_plain }
  let(:expected_groups)                        { [] }
  let(:expect_message_held_notice_sent)        { false }


  it 'delivers the email' do
    validate! :delivered
  end

  context 'when the same message is processed twice' do
    let(:expected_email_recipients){ [] }

    it 'delivers the first message and processes the second as a duplicate' do
      threadable.incoming_emails.create!(params)
      drain_background_jobs!
      sent_emails.clear
      validate! :duplicate
    end
  end


  context "when the recipients do not match a organization" do
    let(:recipient){ 'poopnozzle@threadable.com' }
    let(:to)       { 'Poop Nozzle <poopnozzle@threadable.com>' }

    let(:expected_organization)  { nil }
    let(:expected_parent_message){ nil }
    let(:expected_conversation)  { nil }
    let(:expected_creator)       { nil }
    it 'bounces the incoming email' do
      validate! :bounced
    end
  end


  context "when the recipient email address matches an organization" do
    let(:recipient){ expected_organization.email_address }
    let(:to)       { expected_organization.formatted_email_address }

    let(:expected_organization)      { threadable.organizations.find_by_slug!('raceteam') }
    let(:expected_sent_email_to){ [recipient] }
    let(:expected_sent_email_cc){ '' }

    context 'the subject contains only stuff that is stripped and spaces' do
      let(:subject) { '[RaceTeam] ' }

      context 'and the body is present' do
        let(:stripped_text) { "Just you, sir? Don't worry, Master Wayne. It takes a little time to get back in the swing of things." }
        let(:expected_sent_email_subject) { "[RaceTeam] Just you, sir? Don't worry, Master Wayne. It..." }
        let(:expected_message_subject) { subject }

        it 'copies the first 8 words of the body to the subject' do
          validate! :delivered
        end
      end

      context 'and the body is blank' do
        let(:recipient){ expected_organization.email_address }
        let(:to)       { expected_organization.formatted_email_address }

        let(:stripped_text) { '' }

        let(:expected_parent_message){ nil }
        let(:expected_conversation)  { nil }
        let(:expected_creator)       { nil }
        it 'bounces the incoming email' do
          validate! :bounced
        end
      end

      context 'and the body contains no characters that can make a slug, but is not blank' do
        let(:recipient){ expected_organization.email_address }
        let(:to)       { expected_organization.formatted_email_address }

        let(:stripped_text) { '-- ' }

        let(:expected_parent_message){ nil }
        let(:expected_conversation)  { nil }
        let(:expected_creator)       { nil }
        it 'bounces the incoming email' do
          validate! :bounced
        end
      end
    end

    context 'the subject begins with some form of re:' do
      let(:subject) { 'Re: [RaceTeam] this is the subject' }
      let(:expected_conversation_subject) { 'this is the subject' }
      let(:expected_message_subject) { 'Re: [RaceTeam] this is the subject' }
      let(:expected_sent_email_subject) { 'Re: [RaceTeam] this is the subject' }
      it 'keeps the re: at the beginning' do
        validate! :delivered
      end
    end

    context 'a parent message cannot be found' do
      let(:in_reply_to){ '' }
      let(:references) { '' }
      let(:expected_parent_message){ nil }

      context "and the sender is a organization member" do
        let(:from)          { "Alice Neilson <alice@ucsd.example.com>" }
        let(:envelope_from) { "<alice@ucsd.example.com>" }
        let(:sender)        { "alice@ucsd.example.com" }

        let(:expected_conversation)      { expected_organization.conversations.latest }
        let(:expected_creator)           { threadable.users.find_by_email_address(sender) }
        let(:expected_sent_email_smtp_envelope_from){ expected_organization.email_address }
        let(:expected_sent_email_subject){ "#{expected_conversation.subject_tag} #{subject}" }
        let(:expected_email_recipients) { ["yan@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }

        it 'delivers the email' do
          validate! :delivered
        end
      end

      context "and the sender is not a user or a organization member" do
        let(:from)          { "Elizabeth Pickles <elizabeth@pickles.io>" }
        let(:envelope_from) { "<elizabeth@pickles.io>" }
        let(:sender)        { "elizabeth@pickles.io" }

        let(:expected_conversation){ nil }
        let(:expected_creator     ){ nil }
        let(:expect_message_held_notice_sent){ true }

        it 'holds the incoming email' do
          validate! :held
        end

        context 'but the message is to a group that accepts all messages' do
          let(:recipient) { 'raceteam+electronics+fundraising@127.0.0.1' }
          let(:to)        { '"UCSD Electric Racing: Electronics" <raceteam+electronics+fundraising@127.0.0.1>' }

          before do
            expected_organization.groups.find_by_slug!('electronics').update(hold_messages: false)
          end

          let(:expected_sent_email_cc) { from }
          let(:expected_conversation)  { expected_organization.conversations.latest }
          let(:expected_creator)       { threadable.users.find_by_email_address(sender) }
          let(:expected_groups)        { ['Electronics', 'Fundraising'] }
          let(:expected_email_recipients) { ["alice@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "nadya@ucsd.example.com"] }
          let(:expected_sent_email_to) { Set["raceteam+electronics@127.0.0.1", "raceteam+fundraising@127.0.0.1"] }
          it 'delivers the email' do
            validate! :delivered
          end
        end
      end

      context "and the sender is a user but not a organization member" do
        let(:from)          { 'Ritsuko Akagi <ritsuko@sfhealth.example.com>' }
        let(:envelope_from) { '<ritsuko@sfhealth.example.com>' }
        let(:sender)        { 'ritsuko@sfhealth.example.com' }

        let(:expected_conversation){ nil }
        let(:expected_creator)     { threadable.users.find_by_email_address(sender) }
        let(:expect_message_held_notice_sent){ true }

        it 'holds the incoming email' do
          validate! :held
        end
      end
    end

    context 'a parent message can be found via the In-Reply-To header' do
      let(:in_reply_to){ expected_parent_message.message_id_header }
      let(:references) { '' }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug!('welcome-to-our-threadable-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      let(:expected_email_recipients){ ["alice@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
      let(:expected_sent_email_subject) { "Re: [RaceTeam] OMG guys I love threadable!" }

      it 'delivers the email' do
        validate! :delivered
      end
    end

    context 'a parent message can be found via the References header' do
      let(:in_reply_to){ '' }
      let(:references) { expected_conversation.messages.all.map(&:message_id_header).join(' ') }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-threadable-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      let(:expected_email_recipients){ ["alice@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
      let(:expected_sent_email_subject) { "Re: [RaceTeam] OMG guys I love threadable!" }

      it 'delivers the email' do
        validate! :delivered
      end
    end

    context 'a parent message can be found via the Thread-Index header' do
      let(:in_reply_to){ '' }
      let(:references) { '' }

      let(:parent_thread_index_decoded) { "#{SecureRandom.uuid}12345" }
      let(:thread_index) { Base64.strict_encode64("#{parent_thread_index_decoded}67890") }
      let(:thread_topic) { expected_conversation.subject }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-threadable-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      let(:expected_email_recipients){ ["alice@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
      let(:expected_sent_email_subject) { "Re: [RaceTeam] OMG guys I love threadable!" }

      before do
        expected_parent_message.update(thread_index_header: Base64.strict_encode64(parent_thread_index_decoded))
      end

      it 'delivers the email' do
        validate! :delivered
      end
    end

    context 'a parent message can be found via the In-Reply-To header and the References header' do
      let(:in_reply_to){ expected_parent_message.message_id_header }
      let(:references) { expected_organization.conversations.find_by_slug("layup-body-carbon").messages.all.map(&:message_id_header).join(' ') }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-threadable-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      let(:expected_email_recipients){ ["alice@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
      let(:expected_sent_email_subject) { "Re: [RaceTeam] OMG guys I love threadable!" }

      it 'prefers the In-Reply-To message id over the References message ids' do
        validate! :delivered
      end
    end

    context 'a parent message can be found' do
      let(:in_reply_to){ expected_parent_message.message_id_header }
      let(:references) { '' }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-threadable-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      let(:expected_sent_email_subject) { "Re: [RaceTeam] OMG guys I love threadable!" }

      context 'but the creator exists but is not a organization member' do
        let(:from)         { 'Anil Kapoor <anil@sfhealth.example.com>' }
        let(:envelope_from){ '<anil@sfhealth.example.com>' }
        let(:sender)       { 'anil@sfhealth.example.com' }

        let(:expected_creator)         { threadable.users.find_by_email_address!(sender) }
        let(:expected_sent_email_cc)   { 'Anil Kapoor <anil@sfhealth.example.com>' }
        let(:expected_email_recipients){ ["alice@ucsd.example.com", "yan@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }

        it 'it delivers the message and copies the non-member to the cc header' do
          validate! :delivered
        end
      end

      context 'but the creator does not exist' do
        let(:from)         { 'Who Knows <who.knows@example.com>' }
        let(:envelope_from){ '<who.knows@example.com>' }
        let(:sender)       { 'who.knows@example.com' }

        let(:expected_creator){ nil }
        let(:expected_sent_email_cc){ 'Who Knows <who.knows@example.com>' }
        let(:expected_email_recipients){ ["alice@ucsd.example.com", "yan@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }

        it 'it delivers the message and copies the unknown email address to the cc header' do
          validate! :delivered
        end
      end

      context 'and the creator is a organization member' do
        let(:from)         { "Alice Neilson <alice@ucsd.example.com>" }
        let(:envelope_from){ '<alice@ucsd.example.com>' }
        let(:sender)       { 'alice@ucsd.example.com' }

        let(:expected_creator){ threadable.users.find_by_email_address!(sender) }
        let(:expected_email_recipients){ ["yan@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }

        it 'it delivers the message' do
          validate! :delivered
        end

        context 'and the subject does not contain Re:' do
          let(:subject) { 'I am a coconut' }
          let(:expected_message_subject) { 'I am a coconut' }
          let(:expected_sent_email_subject) { 'Re: [RaceTeam] I am a coconut'}

          it 'it delivers the message and adds Re: to the subject because Apple Mail sucks' do
            validate! :delivered
          end
        end

        context 'and the body contains commands' do
          let(:body_html){
            %(<p>&amp;undone</p>\n\n\n)+
            %(<p>I think we're quite through here</p>\n\n)+
            %(seriously what is going on.\n)
          }
          let(:body_plain){
            %(&undone\n\n\n)+
            %(I think we're quite through here\n\n)+
            %(seriously what is going on.\n)
          }
          let(:stripped_html){ body_html }
          let(:stripped_text){ body_plain }

          let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
          let(:expected_sent_email_reply_to)          { expected_organization.formatted_task_email_address }

          let(:expect_conversation_to_be_a_task) { true }
          let(:expect_task_to_be_done)           { false }
          let(:expected_sent_email_to)           { ['raceteam+task@127.0.0.1'] }
          let(:expected_sent_email_subject)      { "Re: [✔︎][RaceTeam] OMG guys I love threadable!" }
          let(:expected_email_recipients)        { ["yan@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
          let(:expected_conversation)            { expected_organization.conversations.find_by_slug('layup-body-carbon') }
          let!(:expected_parent_message)         { expected_conversation.messages.latest }

          it 'delivers the email' do
            validate! :delivered
          end
        end

        context 'but the body contains only commands and whitespace' do
          let(:body_html){
            %(&amp;done\n)
          }
          let(:body_plain){
            %(&done\n)
          }
          let(:stripped_html){ body_html }
          let(:stripped_text){ body_plain }

          let(:expect_conversation_to_be_a_task)      { true }
          let(:expected_conversation)          { expected_organization.conversations.find_by_slug('layup-body-carbon') }
          let!(:expected_parent_message)       { expected_conversation.messages.latest }

          it 'delivers the email' do
            validate! :dropped
          end
        end
      end
    end

    context 'the recipient email address contains a group that does not exist and a group that does' do
      let(:recipient) { 'raceteam+hotdogs+fundraising@127.0.0.1' }
      let(:to)        { 'raceteam+hotdogs+fundraising@127.0.0.1' }

      let(:expected_groups){ ['Fundraising'] }
      let(:expected_sent_email_to){ ["raceteam+fundraising@127.0.0.1"] }
      let(:expected_sent_email_smtp_envelope_from){ "raceteam+fundraising@127.0.0.1" }
      let(:expected_email_recipients){ ["alice@ucsd.example.com", "nadya@ucsd.example.com"] }
      let(:expected_sent_email_reply_to){ %("UCSD Electric Racing: Fundraising" <raceteam+fundraising@127.0.0.1>) }
      it 'deliveres the email to the group that exists' do
        validate! :delivered
      end
    end

    context 'the recipient email address contains one group that do not exist' do
      let(:recipient) { 'raceteam+pandapoop@127.0.0.1' }
      let(:to)        { 'raceteam+pandapoop@127.0.0.1' }

      let(:expected_groups){ [] }
      let(:expected_sent_email_to){ ["raceteam@127.0.0.1"] }
      it 'deliveres the email ungrouped' do
        validate! :delivered
      end
    end

    context 'the recipient email address contains only valid groups' do
      let(:from)         { 'Alice Neilson <alice@ucsd.example.com>'}
      let(:envelope_from){ '<alice@ucsd.example.com>' }
      let(:sender)       { 'alice@ucsd.example.com' }
      let(:recipient)    { 'raceteam+electronics+fundraising@127.0.0.1' }
      let(:to)           { '"UCSD Electric Racing: Electronics" <raceteam+electronics+fundraising@127.0.0.1>' }

      let(:expected_creator)         { threadable.users.find_by_email_address!(sender) }
      let(:expected_email_recipients){ ["tom@ucsd.example.com", "bethany@ucsd.example.com", "nadya@ucsd.example.com"] }
      let(:expected_groups)          { ['Electronics', 'Fundraising'] }
      let(:expected_sent_email_to)   { ["raceteam+electronics@127.0.0.1", "raceteam+fundraising@127.0.0.1"].to_set }

      it "delivers the message to only those groups' members" do
        validate! :delivered
      end

      context "and multiple recipients are specified on a single message" do
        let(:recipient)    { 'raceteam+electronics@127.0.0.1, raceteam+fundraising@127.0.0.1' }
        let(:posted_attachments) { Set.new() }
        let(:check_attachments) { false }

        it "creates two incoming emails and delivers the message to only those groups' members" do
          # we are asserting on the contents of the second email, but there is only one message.
          validate! :delivered
        end
      end

      context "and the conversation is to a single group" do
        let(:recipient) { 'raceteam+electronics@127.0.0.1' }
        let(:to)        { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }

        let(:expected_groups)                        { ['Electronics'] }
        let(:expected_sent_email_reply_to)           { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }
        let(:expected_sent_email_to)                 { ["raceteam+electronics@127.0.0.1"] }
        let(:expected_email_recipients)              { ["tom@ucsd.example.com", "bethany@ucsd.example.com"] }
        let(:expected_sent_email_smtp_envelope_from) { 'raceteam+electronics@127.0.0.1' }

        it "delivers the message to only those groups' members" do
          validate! :delivered
        end

        context "and the group is identified using -- instead of +" do
          let(:recipient) { 'raceteam--electronics@127.0.0.1' }
          let(:to)        { '"UCSD Electric Racing: Electronics" <raceteam--electronics@127.0.0.1>' }

          it "delivers the message to only those groups' members" do
            validate! :delivered
          end
        end

        context 'and the to header contains a malformed but mostly correct To address' do
          context 'contains unquoted colons' do
            let(:to)        { 'UCSD Electric Racing: Electronics <raceteam+electronics@127.0.0.1>' }

            it "delivers the message anyway, dammit" do
              validate! :delivered
            end
          end

          context 'contains unquoted unicode' do
            let(:to)        { 'Ravi S. Rāmphal <ravi@apportable.com>, "UCSD Electric Racing: Electronics" <raceteam--electronics@127.0.0.1>' }
            let(:expected_sent_email_to)                 { ['ravi@apportable.com', "raceteam+electronics@127.0.0.1"] }


            it "delivers the message anyway, dammit" do
              validate! :delivered
            end
          end
        end

        context 'and the header contains a malformed but mostly correct From address' do
          context 'contains unquoted unicode' do
            let(:from)        { 'Ravi S. Rāmphal <ravi@apportable.com>' }

            it "delivers the message anyway, dammit" do
              validate! :delivered
            end
          end
        end
      end

      context 'and the message is a reply to a conversation that is in different group(s)' do
        let(:in_reply_to){ expected_parent_message.message_id_header }

        let(:expected_parent_message)     { expected_conversation.messages.latest }

        context do
          let(:expected_conversation)        { expected_organization.conversations.find_by_slug('parts-for-the-motor-controller') }
          let(:expected_groups)              { ['Electronics', 'Fundraising'] }
          let(:expected_sent_email_list_id)  { "UCSD Electric Racing <raceteam.127.0.0.1>" }
          let(:expected_sent_email_list_post){ "<mailto:#{expected_conversation.list_post_email_address.sub(/\+(electronics|fundraising)/,'')}>, <#{compose_conversation_url(expected_organization, 'my')}>" }
          let(:expected_sent_email_subject) { "Re: [RaceTeam] OMG guys I love threadable!" }
          it 'adds the new groups to the conversation' do
            validate! :delivered
          end
        end

        context 'and the conversation was previously removed from one of those groups' do
          let(:to) { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>, "UCSD Electric Racing: Fundraising" <raceteam+fundraising@127.0.0.1>' }
          let(:expected_sent_email_to) { ['raceteam+fundraising@127.0.0.1'] }

          let(:expected_conversation)                  { expected_organization.conversations.find_by_slug('how-are-we-paying-for-the-motor-controller') }
          let(:expected_groups)                        { ['Fundraising'] }
          let(:expected_email_recipients)              { ['nadya@ucsd.example.com'] }
          let(:expected_sent_email_reply_to)           { '"UCSD Electric Racing: Fundraising" <raceteam+fundraising@127.0.0.1>' }
          let(:expected_sent_email_smtp_envelope_from) { 'raceteam+fundraising@127.0.0.1' }
          let(:expected_sent_email_subject) { "Re: [RaceTeam+Fundraising] OMG guys I love threadable!" }

          it 'does not add the previously-used groups to the conversation' do
            validate! :delivered
          end
        end
      end

      context 'the message is a duplicate of an already received message, but the recipient is to different groups' do
        let(:to)        { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }
        let(:recipient) { 'raceteam+electronics@127.0.0.1' }

        let(:expected_groups)          { ['Electronics', 'Fundraising'] }
        let(:expected_email_recipients){ ["tom@ucsd.example.com", "bethany@ucsd.example.com"] }

        before do
          # this simulates the same message being recieved twice with different recipients, as if we were in the TO and the CC headers
          first_incoming_email = threadable.incoming_emails.create!(params.merge("recipient" => 'raceteam+fundraising@127.0.0.1')).first
          job = find_background_jobs(ProcessIncomingEmailWorker, args: [threadable.env, first_incoming_email.id]).first

          email_recipients = ['nadya@ucsd.example.com'].map do |email_address|
            expected_organization.members.find_by_email_address!(email_address)
          end

          threadable_env = threadable.env.merge(
            "current_user_id" => threadable.users.find_by_email_address!('alice@ucsd.example.com').user_id,
            "worker" => true,
          )

          Threadable.transaction do
            run_background_job(job)
            first_incoming_email.reload!
            email_recipients.each do |recipient|
              expect(first_incoming_email.message).to_not be_sent_to(recipient)
              assert_background_job_not_enqueued(SendEmailWorker, args: [threadable_env, 'conversation_message', expected_organization.id, first_incoming_email.message.id, recipient.id])
            end
          end
          email_recipients.each do |recipient|
            expect(first_incoming_email.message).to be_sent_to(recipient)
            assert_background_job_enqueued(SendEmailWorker, args: [threadable_env, 'conversation_message', expected_organization.id, first_incoming_email.message.id, recipient.id])
          end
          drain_background_jobs!
          sent_emails.clear
        end

        it 'adds the conversation to those groups, delivers the message only to the recipients from the newly added groups, who are not in the previous groups' do
          validate! :duplicate
        end
      end
    end
  end

  context 'and the subject is more than 255 characters' do
    let(:subject){ 'A☃'*250 }

    let(:expected_conversation_subject){ subject[0..254] }
    let(:expected_message_subject)     { subject[0..254] }
    let(:expected_sent_email_subject)  { "#{expected_conversation.subject_tag} #{subject[0..254]}" }
    let(:expected_parent_message)      { nil }

    it 'truncates the subject to 255 characters' do
      validate! :delivered
    end
  end

  context 'and the subject is all unicode characters' do
    let(:subject){ '☃☃☃☃☃' }
    it 'creates a valid slug for the conversation'
  end

  context "and the subject is in Japanese" do
    let(:subject) { "おはいよございます！げんきですか？" }
    let(:expected_message_subject)   { "おはいよございます！げんきですか？" }
    let(:expected_sent_email_subject){ "[RaceTeam] おはいよございます！げんきですか？" }

    it 'delivers the incoming email' do
      validate! :delivered
    end
  end

  context "and the message was sent to the +task address" do
    let(:recipient){ expected_organization.task_email_address }
    let(:to)       { expected_organization.formatted_task_email_address }

    let(:expect_conversation_to_be_a_task)      { true }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expected_sent_email_to)                { [expected_organization.task_email_address] }
    let(:expected_sent_email_subject)           { "[✔︎][RaceTeam] #{subject}" }
    let(:expected_sent_email_reply_to)          { expected_organization.formatted_task_email_address }

    it 'creates the conversation as a task' do
      validate! :delivered
    end

    context 'and the -- backup character was used' do
      let(:recipient){ expected_organization.task_email_address.gsub('+', '--') }
      let(:to)       { expected_organization.formatted_task_email_address.gsub('+', '--') }

      it 'creates the conversation as a task' do
        validate! :delivered
      end
    end
  end

  context "and the subject contains [task]" do
    let(:subject){ '[task] pickup some cheese' }

    let(:expect_conversation_to_be_a_task)      { true }
    let(:expected_message_subject)              { '[task] pickup some cheese' }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expected_sent_email_to)                { [expected_organization.task_email_address] }
    let(:expected_sent_email_subject)           { "[✔︎][RaceTeam] pickup some cheese" }
    let(:expected_sent_email_reply_to)          { expected_organization.formatted_task_email_address }

    it 'creates the conversation as a task' do
      validate! :delivered
    end

    context "but the message was cc'd to the regular organization address" do
      let(:to){ 'someone else <someone.else@example.com>' }
      let(:cc){ 'UCSD Electric Racing <raceteam@127.0.0.1>' }

      let(:expected_sent_email_to){ ['someone.else@example.com'] }
      let(:expected_sent_email_cc){ expected_organization.formatted_task_email_address }

      it 'rewrites the organization email address to use the organization task email address' do
        validate! :delivered
      end
    end
  end


  context "and the subject contains the bare form of [✔]" do
    let(:subject){ '[✔] pickup some cake' }

    let(:expect_conversation_to_be_a_task)      { true }
    let(:expected_message_subject)              { '[✔] pickup some cake' }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expected_sent_email_to)                { [expected_organization.task_email_address] }
    let(:expected_sent_email_subject)           { "[✔︎][RaceTeam] pickup some cake" }
    let(:expected_sent_email_reply_to)          { expected_organization.formatted_task_email_address }

    it 'creates the conversation as a task' do
      validate! :delivered
    end
  end

  context "and the subject contains the text form of [✔︎]" do
    let(:subject){ '[✔︎] pickup some cake' }

    let(:expect_conversation_to_be_a_task)      { true }
    let(:expected_message_subject)              { '[✔︎] pickup some cake' }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expected_sent_email_to)                { [expected_organization.task_email_address] }
    let(:expected_sent_email_subject)           { "[✔︎][RaceTeam] pickup some cake" }
    let(:expected_sent_email_reply_to)          { expected_organization.formatted_task_email_address }

    it 'creates the conversation as a task' do
      validate! :delivered
    end
  end

  context "and the subject contains the emoji form of [✔️]" do
    let(:subject){ '[✔️] pickup some cake' }

    let(:expect_conversation_to_be_a_task)      { true }
    let(:expected_message_subject)              { '[✔️] pickup some cake' }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expected_sent_email_to)                { [expected_organization.task_email_address] }
    let(:expected_sent_email_subject)           { "[✔︎][RaceTeam] pickup some cake" }
    let(:expected_sent_email_reply_to)          { expected_organization.formatted_task_email_address }

    it 'creates the conversation as a task' do
      validate! :delivered
    end
  end

  # from, envelope from, sender

  context 'when the from address matches a non-member and the envelope from matches a non-member and the sender matches a member' do
    let(:from)                    { 'Hans Zarkov <zarkov@sfhealth.example.com>' }
    let(:envelope_from)           { '<bj@sfhealth.example.com>' }
    let(:sender)                  { 'bob@ucsd.example.com' }
    let(:expected_creator)        { threadable.users.find_by_email_address('bob@ucsd.example.com') }
    let(:expected_email_recipients){ ["alice@ucsd.example.com", "yan@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "nadya@ucsd.example.com"] }
    it 'sets the creator as the user matching the sender address' do
      validate! :delivered
    end
  end

  context 'when the from address matches a non-member and the envelope from matches a member and the sender matches a non-member' do
    let(:from)                    { 'Hans Zarkov <zarkov@sfhealth.example.com>' }
    let(:envelope_from)           { '<bethany@ucsd.example.com>' }
    let(:sender)                  { 'house@sfhealth.example.com' }
    let(:expected_creator)        { threadable.users.find_by_email_address('bethany@ucsd.example.com') }
    let(:expected_email_recipients){ ["alice@ucsd.example.com", "yan@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
    it 'sets the creator as user matching the envelope from address' do
      validate! :delivered
    end
  end

  context 'when the from address matches a member and the envelope from matches a non-member but the sender matches a non-member' do
    let(:from)                    { 'Jonathan Spray <jonathan@ucsd.example.com>' }
    let(:envelope_from)           { '<zarkov@sfhealth.example.com>' }
    let(:sender)                  { 'trapper@sfhealth.example.com' }
    let(:expected_creator)        { threadable.users.find_by_email_address('jonathan@ucsd.example.com') }
    let(:expected_email_recipients){ ["alice@ucsd.example.com", "yan@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
    it 'sets the creator as user matching the from address' do
      validate! :delivered
    end
  end

  context 'when the from, envelope from, and sender are all members' do
    let(:from)                    { 'Jonathan Spray <jonathan@ucsd.example.com>' }
    let(:envelope_from)           { '<bethany@ucsd.example.com>' }
    let(:sender)                  { 'bob@ucsd.example.com' }
    let(:expected_creator)        { threadable.users.find_by_email_address('jonathan@ucsd.example.com') }
    let(:expected_email_recipients){ ["alice@ucsd.example.com", "yan@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
    it 'sets the creator as user matching the from address' do
      validate! :delivered
    end
  end

  context 'when the from is not a user, but the envelope from, and sender are both members' do
    let(:from)                    { 'Some Rando <some-rando@example.com>' }
    let(:envelope_from)           { '<bethany@ucsd.example.com>' }
    let(:sender)                  { 'bob@ucsd.example.com' }
    let(:expected_creator)        { threadable.users.find_by_email_address('bethany@ucsd.example.com') }
    let(:expected_email_recipients){ ["alice@ucsd.example.com", "yan@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }
    it 'sets the creator as user matching the envelope from address' do
      validate! :delivered
    end
  end

  context 'when there are only members in the to header, and the cc is blank' do
    let(:to) { "Alice Neilson <alice@ucsd.example.com>" }
    let(:cc) { '' }

    let(:expected_sent_email_to){ ['raceteam@127.0.0.1'] }
    let(:expected_sent_email_cc){ '' }

    it 'adds the organization to the to' do
      validate! :delivered
    end
  end

  context 'when there are only members in the to header, and the organization is in the CC' do
    let(:to) { "Alice Neilson <alice@ucsd.example.com>" }
    let(:cc) { 'UCSD Electric Racing <raceteam@127.0.0.1>' }

    let(:expected_sent_email_to){ ['raceteam@127.0.0.1'] }
    let(:expected_sent_email_cc){ '' }

    it 'moves the organization from the cc header to the to header' do
      validate! :delivered
    end
  end

  context 'when there are non-members in the to header, and the organization is in the CC' do
    let(:to) { "Frank Rizzo <frank.rizzo@jerkyboys.co>" }
    let(:cc) { 'UCSD Electric Racing <raceteam@127.0.0.1>' }

    let(:expected_sent_email_to){ ['frank.rizzo@jerkyboys.co'] }
    let(:expected_sent_email_cc){ 'UCSD Electric Racing <raceteam@127.0.0.1>' }

    it 'does not move the organization from the cc header to the to header' do
      validate! :delivered
    end
  end

  context 'when there are members in the to header' do
    let(:to) { "Alice Neilson <alice@ucsd.example.com>, Someone Else <someone.else@example.com>, bethany@ucsd.example.com" }

    let(:expected_sent_email_to){ ['someone.else@example.com'] }

    it 'filters members out of the to header' do
      validate! :delivered
    end
  end

  context 'when there are members in the cc header' do
    let(:cc) { "Alice Neilson <alice@ucsd.example.com>, Someone Else <someone.else@example.com>, bethany@ucsd.example.com" }

    let(:expected_sent_email_cc){ 'Someone Else <someone.else@example.com>' }
    it 'filters members out of the cc header' do
      validate! :delivered
    end
  end

  context 'header rearranging: with groups' do
    let(:recipient) { 'raceteam+electronics@127.0.0.1' }
    let(:to)        { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }

    let(:expected_sent_email_to)                 { ['raceteam+electronics@127.0.0.1'] }
    let(:expected_groups)                        { ['Electronics'] }
    let(:expected_sent_email_reply_to)           { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }
    let(:expected_email_recipients)              { ["tom@ucsd.example.com", "bethany@ucsd.example.com"] }
    let(:expected_sent_email_smtp_envelope_from) { 'raceteam+electronics@127.0.0.1' }

    context 'when there are only group members in the to header, and the cc is blank' do
      let(:to) { "Tom Canver <tom@ucsd.example.com>" }
      let(:cc) { '' }

      let(:expected_sent_email_to){ ['raceteam+electronics@127.0.0.1'] }
      let(:expected_sent_email_cc){ '' }

      it 'adds the organization to the to' do
        validate! :delivered
      end
    end

    context 'when the group email address does not include the name-part' do
      let(:to) { 'some@guy.com' }
      let(:cc) { 'raceteam+electronics@127.0.0.1' }

      let(:expected_sent_email_to){ ['some@guy.com'] }
      let(:expected_sent_email_cc){ '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }

      it 'adds the organization to the to' do
        validate! :delivered
      end
    end

    context 'when there are only members in the to header, and the group is in the CC' do
      let(:to) { "Tom Canver <tom@ucsd.example.com>" }
      let(:cc) { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }

      let(:expected_sent_email_to){ ['raceteam+electronics@127.0.0.1'] }
      let(:expected_sent_email_cc){ '' }

      it 'moves the group from the cc header to the to header' do
        validate! :delivered
      end
    end

    context 'when there are only members in the to header, and the group and organization are in the CC' do
      let(:to) { "Tom Canver <tom@ucsd.example.com>" }
      let(:cc) { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>, UCSD Electric Racing <raceteam@127.0.0.1>' }

      let(:expected_sent_email_to){ ['raceteam+electronics@127.0.0.1'] }
      let(:expected_sent_email_cc){ '' }

      it 'moves the group from the cc header to the to header, and removes the organization from the cc header' do
        validate! :delivered
      end
    end

    context 'when the organization is in the to header, and the group is not present in the headers' do
      let(:to) { 'UCSD Electric Racing <raceteam@127.0.0.1>' }
      let(:cc) { '' }

      let(:expected_sent_email_to){ ['raceteam+electronics@127.0.0.1'] }
      let(:expected_sent_email_cc){ '' }

      it 'removes the organization from the to header, and adds the group' do
        validate! :delivered
      end
    end

    context 'when there are non-members in the to header, and the group is in the CC' do
      let(:to) { "Frank Rizzo <frank.rizzo@jerkyboys.co>" }
      let(:cc) { '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }

      let(:expected_sent_email_to){ ['frank.rizzo@jerkyboys.co'] }
      let(:expected_sent_email_cc){ '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>' }

      it 'does not move the group from the cc header to the to header' do
        validate! :delivered
      end
    end

    context 'when there are group members in the to header' do
      let(:to) { "Tom Canver <tom@ucsd.example.com>, Someone Else <someone.else@example.com>, bethany@ucsd.example.com" }

      let(:expected_sent_email_to){ ['someone.else@example.com'] }

      it 'filters group members out of the to header' do
        validate! :delivered
      end
    end

    context 'when there are organization members and group members in the to header' do
      let(:to) { "Alice Neilson <alice@ucsd.example.com>, Someone Else <someone.else@example.com>, bethany@ucsd.example.com" }

      let(:expected_sent_email_to){ ['alice@ucsd.example.com', 'someone.else@example.com'] }

      it 'filters group members out of the to header' do
        validate! :delivered
      end
    end

    context 'when there are group members in the cc header' do
      let(:cc) { "Tom Canver <tom@ucsd.example.com>, Someone Else <someone.else@example.com>, bethany@ucsd.example.com" }

      let(:expected_sent_email_cc){ 'Someone Else <someone.else@example.com>' }
      it 'filters group members out of the cc header' do
        validate! :delivered
      end
    end

    context 'when there are organization members and group members in the cc header' do
      let(:cc) { "Alice Neilson <alice@ucsd.example.com>, Someone Else <someone.else@example.com>, bethany@ucsd.example.com" }

      let(:expected_sent_email_cc){ 'Alice Neilson <alice@ucsd.example.com>, Someone Else <someone.else@example.com>' }
      it 'filters group members out of the cc header' do
        validate! :delivered
      end
    end
  end

  context 'when the message is a reply to a non-task conversation but the message was sent to the organization task email addresss' do
    let(:recipient)  { 'raceteam+task@127.0.0.1' }
    let(:to)         { 'UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>' }
    let(:in_reply_to){ expected_parent_message.message_id_header }
    let(:references) { '' }

    let(:expected_sent_email_subject) { "Re: [RaceTeam] OMG guys I love threadable!" }
    let(:expected_sent_email_to){ ['raceteam@127.0.0.1'] }
    let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-threadable-organization') }
    let(:expected_parent_message){ expected_conversation.messages.latest }
    let(:expected_email_recipients){ ["alice@ucsd.example.com", "tom@ucsd.example.com", "bob@ucsd.example.com", "nadya@ucsd.example.com"] }

    it 'replace that email with the non task version' do
      validate! :delivered
    end
  end

  context 'when the message is a reply to a task but the message was sent to the organization non-task email addresss' do
    let(:recipient)  { 'raceteam@127.0.0.1' }
    let(:to)         { 'UCSD Electric Racing Tasks <raceteam@127.0.0.1>' }
    let(:in_reply_to){ expected_parent_message.message_id_header }
    let(:references) { '' }

    let(:expected_sent_email_subject) { "Re: [✔︎][RaceTeam] OMG guys I love threadable!" }
    let(:expected_sent_email_to){ ['raceteam+task@127.0.0.1'] }
    let(:expected_conversation)  { expected_organization.conversations.find_by_slug('layup-body-carbon') }
    let(:expected_email_recipients){ ["alice@ucsd.example.com", "tom@ucsd.example.com", "nadya@ucsd.example.com", "bob@ucsd.example.com"] }
    let(:expected_parent_message){ expected_conversation.messages.latest }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expect_conversation_to_be_a_task) { true }
    let(:expect_task_to_be_done) { true }
    let(:expected_sent_email_subject){ "[✔︎][RaceTeam] #{subject}" }
    let(:expected_sent_email_reply_to){ expected_organization.formatted_task_email_address }
    let(:expected_sent_email_subject) { "Re: [✔︎][RaceTeam] OMG guys I love threadable!" }
    it 'replace that email with the task version' do
      validate! :delivered
    end
  end

  context 'when the recipient is at covered.io' do
    let(:recipient) { 'raceteam@covered.io' }
    let(:to)        { 'UCSD Electric Racing <raceteam@covered.io>' }
    it 'replaces covered.io with threadable.com' do
      validate! :delivered
    end
  end

  context 'when the recipient is at covered.io' do
    let(:recipient) { 'raceteam@covered.io' }
    let(:to)        { 'UCSD Electric Racing <raceteam@covered.io>, Mr. Race Team <raceteam@example.com>' }
    let(:expected_sent_email_to)   { ["raceteam@127.0.0.1", "raceteam@example.com"] }
    it 'replaces covered.io with threadable.com' do
      validate! :delivered
    end
  end

  context 'when the recipient group has an alias' do
    let(:recipient)                              { 'raceteam+press@covered.io' }
    let(:expected_sent_email_to)                 { ["press@ucsd.example.com"] }
    let(:expected_email_recipients)              { ["tom@ucsd.example.com", "nadya@ucsd.example.com"] }
    let(:expected_groups)                        { ['Press'] }
    let(:expected_sent_email_smtp_envelope_from) { 'raceteam+press@127.0.0.1' }
    let(:expected_sent_email_reply_to)           { 'Press Enquiries <press@ucsd.example.com>' }
    let(:expected_sent_email_list_id)            { '"Press Enquiries" <press.ucsd.example.com>' }

    context 'when the message is to the non-aliased address' do
      let(:to)        { 'UCSD Electric Racing <raceteam+press@covered.io>' }
      it 'translates the header addresses to the alias' do
        validate! :delivered
      end
    end

    context 'when the message is to the aliased address' do
      let(:to)        { 'UCSD Electric Racing <raceteam+press@covered.io>' }
      it 'preserves the alias address in the headers' do
        validate! :delivered
      end
    end
  end

  context 'when the organization holds all messages' do
    before do
      expected_organization.hold_all_messages!
    end

    context 'and the sender is a member' do
      let(:expected_conversation){ nil }
      let(:expect_message_held_notice_sent){ false }
      it 'holds all messages' do
        validate! :held
      end
    end

    context 'and the sender is an owner' do
      let(:from)         { 'Alice Neilson <alice@ucsd.example.com>' }
      let(:envelope_from){ '<alice@ucsd.example.com>' }
      let(:sender)       { 'alice@ucsd.example.com' }

      let(:expected_creator)          { threadable.users.find_by_email_address('alice@ucsd.example.com') }
      let(:expected_email_recipients) { ["yan@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "nadya@ucsd.example.com", "bob@ucsd.example.com"] }

      it 'delivers the messages' do
        validate! :delivered
      end
    end

  end

end
