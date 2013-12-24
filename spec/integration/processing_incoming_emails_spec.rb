require 'spec_helper'

describe "processing incoming emails 2" do

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
    )
  end


  def validate! result
    post emails_url, params
    expect(response).to be_ok

    incoming_email = covered.incoming_emails.latest

    # before being processed

    expect( incoming_email.params['timestamp']        ).to eq params['timestamp']
    expect( incoming_email.params['token']            ).to eq params['token']
    expect( incoming_email.params['signature']        ).to eq params['signature']
    expect( incoming_email.params['recipient']        ).to eq params['recipient']
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
    expect( incoming_email.subject                ).to eq(subject)
    expect( incoming_email.message_id             ).to eq(message_id)
    expect( incoming_email.from                   ).to eq(from)
    expect( incoming_email.envelope_from          ).to eq(envelope_from)
    expect( incoming_email.sender                 ).to eq(sender)
    expect( incoming_email.recipient              ).to eq(recipient)
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
    ]
    expect( incoming_email.body_html      ).to eq(body_html)
    expect( incoming_email.body_plain     ).to eq(body_plain)
    expect( incoming_email.stripped_html  ).to eq(stripped_html)
    expect( incoming_email.stripped_plain ).to eq(stripped_text)

    # process incoming email
    drain_background_jobs!
    incoming_email = covered.incoming_emails.find_by_id(incoming_email.id) # reload

    # after being processed
    case result
    when :bounced
      expect( incoming_email ).to     be_bounced
      expect( incoming_email ).to_not be_held
      expect( incoming_email ).to_not be_delivered
    when :held
      expect( incoming_email ).to_not be_bounced
      expect( incoming_email ).to     be_held
      expect( incoming_email ).to_not be_delivered
    when :delivered
      expect( incoming_email ).to_not be_bounced
      expect( incoming_email ).to_not be_held
      expect( incoming_email ).to     be_delivered
    else
      raise "expect result to :bounced, :held, or :delivered. got #{result.inspect}"
    end

    expect( incoming_email.organization        ).to eq expected_organization
    expect( incoming_email.parent_message ).to eq expected_parent_message
    expect( incoming_email.conversation   ).to eq expected_conversation
    expect( incoming_email.creator        ).to eq expected_creator

    if result == :bounced || result == :held
      expect( incoming_email.message                    ).to be_nil
      expect( incoming_email.params['attachment-count'] ).to eq attachments.count.to_s
      expect( incoming_email.params['attachment-1']     ).to be_present
      expect( incoming_email.params['attachment-2']     ).to be_present
      expect( incoming_email.params['attachment-3']     ).to be_present

      if result == :held
        # held mail gets sent an auto-response
        held_notice = sent_emails.first
        expect( held_notice.smtp_envelope_from ).to eq "no-reply-auto@#{covered.email_host}"
        expect( held_notice.smtp_envelope_to   ).to eq [envelope_from.gsub(/[<>]/, '')]
        expect( held_notice.to                 ).to eq [envelope_from.gsub(/[<>]/, '')]
        expect( held_notice.from               ).to eq ["support+message-held@#{covered.email_host}"]
        expect( held_notice.subject            ).to eq "[message held] #{subject}"

        expect( held_notice.header['Reply-To'].to_s       ).to eq "Covered message held <support+message-held@#{covered.email_host}>"
        expect( held_notice.header['In-Reply-To'].to_s    ).to eq incoming_email.message_id
        expect( held_notice.header['References'].to_s     ).to eq incoming_email.message_id
        expect( held_notice.header['Auto-Submitted'].to_s ).to eq 'auto-replied'
      end

      return
    end

    # only validating delivered messages beyond this point


    expect( incoming_email.message ).to be_present
    expect( incoming_email.conversation ).to be_present

    message      = covered.messages.latest
    conversation = covered.conversations.latest

    expect( incoming_email.message      ).to eq message
    expect( incoming_email.conversation ).to eq conversation
    expect( message.conversation        ).to eq conversation

    if expect_conversation_to_be_a_task
      expect( conversation ).to be_task
    else
      expect( conversation ).to_not be_task
    end



    expect( incoming_email.params['attachment-count'] ).to be_nil
    expect( incoming_email.params['attachment-1']     ).to be_nil
    expect( incoming_email.params['attachment-2']     ).to be_nil
    expect( incoming_email.params['attachment-3']     ).to be_nil

    incoming_email_attachments = incoming_email.attachments.all.map do |attachment|
      [attachment.filename, attachment.mimetype, attachment.content]
    end.to_set

    posted_attachments = attachments.map do |attachment|
      [attachment.original_filename, attachment.content_type, File.read(attachment.path)]
    end.to_set

    expect(incoming_email_attachments).to eq posted_attachments


    expect( message.organization      ).to eq expected_organization
    expect( message.conversation      ).to eq expected_conversation
    expect( message.message_id_header ).to eq message_id
    expect( message.to_header         ).to eq to
    expect( message.cc_header         ).to eq cc
    expect( message.date_header       ).to eq date.rfc2822
    expect( message.references_header ).to eq references
    expect( message.subject           ).to eq expected_message_subject
    expect( message.body_plain        ).to eq body_plain
    expect( message.body_html         ).to eq body_html
    expect( message.stripped_html     ).to eq stripped_html
    expect( message.stripped_plain    ).to eq stripped_text
    expect( message.attachments.all   ).to eq incoming_email.attachments.all


    recipients = message.conversation.recipients.all.reject do |user|
      message.creator.same_user?(user) if message.creator
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
      expect( email.to                              ).to eq expected_sent_email_to
      expect( email.header[:Cc].to_s                ).to eq expected_sent_email_cc
      expect( email.smtp_envelope_to.length         ).to eq 1
      expect( recipient_email_addresses             ).to include email.smtp_envelope_to.first
      expect( email.smtp_envelope_from              ).to eq expected_sent_email_smtp_envelope_from
      expect( email.subject                         ).to eq expected_sent_email_subject
      expect( email.html_content                    ).to include body_html
      expect( email.text_content                    ).to include body_plain
      expect( email.header['Reply-To'].to_s         ).to eq expected_sent_email_reply_to
      expect( email.header['List-ID'].to_s          ).to eq expected_sent_email_list_id
      expect( email.header['List-Archive'].to_s     ).to eq expected_sent_email_list_archive
      expect( email.header['List-Unsubscribe'].to_s ).to be_present
      expect( email.header['List-Post'].to_s        ).to eq expected_sent_email_list_post
    end
  end


  # default incoming email params

  let(:subject)      { 'OMG guys I love covered!' }
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
  let(:expected_conversation)                  { covered.conversations.latest }
  let(:expected_creator)                       { covered.users.find_by_email_address('yan@ucsd.example.com') }
  let(:expected_organization)                       { covered.organizations.find_by_slug!('raceteam') }
  let(:expected_conversation_subject)          { 'OMG guys I love covered!' }
  let(:expected_message_subject)               { 'OMG guys I love covered!' }
  let(:expect_conversation_to_be_a_task)       { false }
  let(:expected_sent_email_to)                 { ['raceteam@127.0.0.1'] }
  let(:expected_sent_email_cc)                 { '' }
  let(:expected_sent_email_subject)            { "[RaceTeam] OMG guys I love covered!" }
  let(:expected_sent_email_smtp_envelope_from) { 'raceteam@127.0.0.1' }
  let(:expected_sent_email_reply_to)           { 'UCSD Electric Racing <raceteam@127.0.0.1>' }
  let(:expected_sent_email_list_id)            { expected_organization.formatted_list_id }
  let(:expected_sent_email_list_archive)       { "<#{organization_conversations_url(expected_organization)}>" }
  let(:expected_sent_email_list_post)          { "<mailto:#{expected_organization.email_address}>, <#{new_organization_conversation_url(expected_organization)}>" }


  it 'delivers the email' do
    validate! :delivered
  end


  context "when the recipients do not match a organization" do
    let(:recipient)    { 'poopnozzle@covered.io' }
    let(:to)           { 'Poop Nozzle <poopnozzle@covered.io>' }

    let(:expected_organization)       { nil }
    let(:expected_parent_message){ nil }
    let(:expected_conversation)  { nil }
    let(:expected_creator)       { nil }
    it 'bounces the incoming email' do
      validate! :bounced
    end
  end


  context "when the recipient email address matches a organization" do
    let(:recipient){ expected_organization.email_address }
    let(:to)       { expected_organization.formatted_email_address }

    let(:expected_organization)      { covered.organizations.find_by_slug!('raceteam') }
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
    end

    context 'a parent message cannot be found' do
      let(:in_reply_to){ '' }
      let(:references) { '' }
      let(:expected_parent_message){ nil }

      context "and the sender is a organization member" do
        let(:from)          { "Alice Neilson <alice@ucsd.example.com>" }
        let(:envelope_from) { "<alice@ucsd.example.com>" }
        let(:sender)        { "alice@ucsd.example.com" }

        let(:expected_conversation)      { covered.conversations.latest }
        let(:expected_creator)           { covered.users.find_by_email_address(sender) }
        let(:expected_sent_email_smtp_envelope_from){ expected_organization.email_address }
        let(:expected_sent_email_subject){ "[#{expected_organization.subject_tag}] #{subject}" }

        it 'delivers the email' do
          validate! :delivered
        end
      end

      context "and the sender is not a user or a organization member" do
        let(:from)          { "Elizabeth Pickles <elizabeth@pickles.io>" }
        let(:envelope_from) { "<elizabeth@pickles.io>" }
        let(:sender)        { "elizabeth@pickles.io" }

        let(:expected_conversation) { nil }
        let(:expected_creator     ){ nil }

        it 'holds the incoming email' do
          validate! :held
        end
      end

      context "and the sender is a user but not a organization member" do
        let(:from)          { 'Ritsuko Akagi <ritsuko@sfhealth.example.com>' }
        let(:envelope_from) { '<ritsuko@sfhealth.example.com>' }
        let(:sender)        { 'ritsuko@sfhealth.example.com' }

        let(:expected_conversation){ nil }
        let(:expected_creator)     { covered.users.find_by_email_address(sender) }

        it 'holds the incoming email' do
          validate! :held
        end
      end

    end

    context 'a parent message can be found via the In-Reply-To header' do
      let(:in_reply_to){ expected_parent_message.message_id_header }
      let(:references) { '' }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug!('welcome-to-our-covered-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      it 'delivers the email' do
        validate! :delivered
      end
    end

    context 'a parent message can be found via the Referenes header' do
      let(:in_reply_to){ '' }
      let(:references) { expected_conversation.messages.all.map(&:message_id_header).join(' ') }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-covered-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      it 'delivers the email' do
        validate! :delivered
      end
    end

    context 'a parent message can be found via the In-Reply-To header and the Referenes header' do
      let(:in_reply_to){ expected_parent_message.message_id_header }
      let(:references) { expected_organization.conversations.find_by_slug("layup-body-carbon").messages.all.map(&:message_id_header).join(' ') }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-covered-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }
      it 'prefers the In-Reply-To message id over the References message ids' do
        validate! :delivered
      end
    end

    context 'a parent message can be found' do
      let(:in_reply_to){ expected_parent_message.message_id_header }
      let(:references) { '' }

      let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-covered-organization') }
      let(:expected_parent_message){ expected_conversation.messages.latest }

      context 'but the creator exists but is not a organization member' do
        let(:from)         { 'Anil Kapoor <anil@sfhealth.example.com>' }
        let(:envelope_from){ '<anil@sfhealth.example.com>' }
        let(:sender)       { 'anil@sfhealth.example.com' }

        let(:expected_creator){ covered.users.find_by_email_address!(sender) }
        let(:expected_sent_email_cc){ 'Anil Kapoor <anil@sfhealth.example.com>' }
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
        it 'it delivers the message and copies the unknown email address to the cc header' do
          validate! :delivered
        end
      end

      context 'and the creator is a organization member' do
        let(:from)         { "Alice Neilson <alice@ucsd.example.com>" }
        let(:envelope_from){ '<alice@ucsd.example.com>' }
        let(:sender)       { 'alice@ucsd.example.com' }

        let(:expected_creator){ covered.users.find_by_email_address!(sender) }
        it 'it delivers the message' do
          validate! :delivered
        end
      end
    end

  end



  context 'and the subject is more than 255 characters' do
    let(:subject){ 'A☃'*250 }

    let(:expected_conversation_subject){ subject[0..254] }
    let(:expected_message_subject)     { subject[0..254] }
    let(:expected_sent_email_subject)  { "[#{expected_organization.subject_tag}] #{subject[0..254]}" }
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
    let(:expected_sent_email_subject)           { "[✔][RaceTeam] #{subject}" }
    let(:expected_sent_email_reply_to)          { expected_organization.formatted_task_email_address }

    it 'creates the conversation as a task' do
      validate! :delivered
    end
  end

  context "and the subject contains [task]" do
    let(:subject){ '[task] pickup some cheese' }

    let(:expect_conversation_to_be_a_task)      { true }
    let(:expected_message_subject)              { '[task] pickup some cheese' }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expected_sent_email_to)                { [expected_organization.task_email_address] }
    let(:expected_sent_email_subject)           { "[✔][RaceTeam] pickup some cheese" }
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


  context "and the subject contains [✔]" do
    let(:subject){ '[✔] pickup some cake' }

    let(:expect_conversation_to_be_a_task)      { true }
    let(:expected_message_subject)              { '[✔] pickup some cake' }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expected_sent_email_to)                { [expected_organization.task_email_address] }
    let(:expected_sent_email_subject)           { "[✔][RaceTeam] pickup some cake" }
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
    let(:expected_creator)        { covered.users.find_by_email_address('bob@ucsd.example.com') }
    it 'sets the creator as the user matching the sender address' do
      validate! :delivered
    end
  end

  context 'when the from address matches a non-member and the envelope from matches a member and the sender matches a non-member' do
    let(:from)                    { 'Hans Zarkov <zarkov@sfhealth.example.com>' }
    let(:envelope_from)           { '<bethany@ucsd.example.com>' }
    let(:sender)                  { 'house@sfhealth.example.com' }
    let(:expected_creator)        { covered.users.find_by_email_address('bethany@ucsd.example.com') }
    it 'sets the creator as user matching the envelope from address' do
      validate! :delivered
    end
  end

  context 'when the from address matches a member and the envelope from matches a non-member but the sender matches a non-member' do
    let(:from)                    { 'Jonathan Spray <jonathan@ucsd.example.com>' }
    let(:envelope_from)           { '<zarkov@sfhealth.example.com>' }
    let(:sender)                  { 'trapper@sfhealth.example.com' }
    let(:expected_creator)        { covered.users.find_by_email_address('jonathan@ucsd.example.com') }
    it 'sets the creator as user matching the from address' do
      validate! :delivered
    end
  end

  context 'when the from, envelope from, and sender are all members' do
    let(:from)                    { 'Jonathan Spray <jonathan@ucsd.example.com>' }
    let(:envelope_from)           { '<bethany@ucsd.example.com>' }
    let(:sender)                  { 'bob@ucsd.example.com' }
    let(:expected_creator)        { covered.users.find_by_email_address('jonathan@ucsd.example.com') }
    it 'sets the creator as user matching the from address' do
      validate! :delivered
    end
  end

  context 'when the from is not a user, but the envelope from, and sender are both members' do
    let(:from)                    { 'Some Rando <some-rando@example.com>' }
    let(:envelope_from)           { '<bethany@ucsd.example.com>' }
    let(:sender)                  { 'bob@ucsd.example.com' }
    let(:expected_creator)        { covered.users.find_by_email_address('bethany@ucsd.example.com') }
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


  context 'when the message is a reply to a non-task conversation but the message was sent to the organization task email addresss' do
    let(:recipient)  { 'raceteam+task@127.0.0.1' }
    let(:to)         { 'UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>' }
    let(:in_reply_to){ expected_parent_message.message_id_header }
    let(:references) { '' }

    let(:expected_sent_email_to){ ['raceteam@127.0.0.1'] }
    let(:expected_conversation)  { expected_organization.conversations.find_by_slug('welcome-to-our-covered-organization') }
    let(:expected_parent_message){ expected_conversation.messages.latest }
    it 'replace that email with the non task version' do
      validate! :delivered
    end
  end

  context 'when the message is a reply to a task but the message was sent to the organization non-task email addresss' do
    let(:recipient)  { 'raceteam@127.0.0.1' }
    let(:to)         { 'UCSD Electric Racing Tasks <raceteam@127.0.0.1>' }
    let(:in_reply_to){ expected_parent_message.message_id_header }
    let(:references) { '' }

    let(:expected_sent_email_to){ ['raceteam+task@127.0.0.1'] }
    let(:expected_conversation)  { expected_organization.conversations.find_by_slug('layup-body-carbon') }
    let(:expected_parent_message){ expected_conversation.messages.latest }
    let(:expected_sent_email_smtp_envelope_from){ expected_organization.task_email_address }
    let(:expect_conversation_to_be_a_task) { true }
    let(:expected_sent_email_subject){ "[✔][RaceTeam] #{subject}" }
    let(:expected_sent_email_reply_to){ expected_organization.formatted_task_email_address }
    it 'replace that email with the task version' do
      validate! :delivered
    end
  end

end
