require 'spec_helper'

describe "actual broken incoming emails" do


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
    # expect( incoming_email.params['attachment-count'] ).to eq attachments.count.to_s
    # attachments.size.times do |n|
    #   expect( incoming_email.params["attachment-#{n+1}"] ).to be_present
    # end

    # expect( recipient ).to include incoming_email.recipient

    # expect( incoming_email.subject                ).to eq(subject)
    # expect( incoming_email.message_id             ).to eq(message_id)
    # expect( incoming_email.from                   ).to eq(from)
    # expect( incoming_email.envelope_from          ).to eq(envelope_from)
    # expect( incoming_email.sender                 ).to eq(sender)
    # expect( incoming_email.to                     ).to eq(to)
    # expect( incoming_email.cc                     ).to eq(cc)
    # expect( incoming_email.content_type           ).to eq(content_type)
    # expect( incoming_email.date                   ).to eq(date)
    # expect( incoming_email.in_reply_to            ).to eq(in_reply_to)
    # expect( incoming_email.references             ).to eq(references)
    # expect( incoming_email.message_headers.to_set ).to eq Set[
    #   ["X-Envelope-From", envelope_from],
    #   ["Sender",          sender],
    #   ["In-Reply-To",     in_reply_to],
    #   ["References",      references],
    #   ["From",            from],
    #   ["Date",            date.rfc2822],
    #   ["Message-Id",      message_id],
    #   ["Subject",         subject],
    #   ["To",              to],
    #   ["Cc",              cc],
    #   ["Content-Type",    content_type],
    # ]
    # expect( incoming_email.body_html      ).to eq(body_html)
    # expect( incoming_email.body_plain     ).to eq(body_plain)
    # expect( incoming_email.stripped_html  ).to eq(stripped_html)
    # expect( incoming_email.stripped_plain ).to eq(stripped_text)

    # # process incoming email
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

    # expect( incoming_email.organization   ).to eq expected_organization
    # expect( incoming_email.parent_message ).to eq expected_parent_message
    # expect( incoming_email.conversation   ).to eq expected_conversation
    # expect( incoming_email.creator        ).to eq expected_creator

    # if result == :bounced || result == :held || result == :dropped
    #   expect( incoming_email.message                    ).to be_nil
    #   expect( incoming_email.params['attachment-count'] ).to eq attachments.count.to_s
    #   expect( incoming_email.params['attachment-1']     ).to be_present
    #   expect( incoming_email.params['attachment-2']     ).to be_present
    #   expect( incoming_email.params['attachment-3']     ).to be_present

    #   if result == :held
    #     # held mail gets sent an auto-response
    #     held_notice = sent_emails.first
    #     expect( held_notice.smtp_envelope_from ).to eq "no-reply-auto@#{threadable.email_host}"
    #     expect( held_notice.smtp_envelope_to   ).to eq [envelope_from.gsub(/[<>]/, '')]
    #     expect( held_notice.to                 ).to eq [envelope_from.gsub(/[<>]/, '')]
    #     expect( held_notice.from               ).to eq ["support+message-held@#{threadable.email_host}"]
    #     expect( held_notice.subject            ).to eq "[message held] #{subject}"

    #     expect( held_notice.header['Reply-To'].to_s       ).to eq "Threadable message held <support+message-held@#{threadable.email_host}>"
    #     expect( held_notice.header['In-Reply-To'].to_s    ).to eq incoming_email.message_id
    #     expect( held_notice.header['References'].to_s     ).to eq incoming_email.message_id
    #     expect( held_notice.header['Auto-Submitted'].to_s ).to eq 'auto-replied'
    #   end

    #   return
    # end

    # # only validating delivered/duplicate messages beyond this point


    # expect( incoming_email.message ).to be_present
    # expect( incoming_email.conversation ).to be_present

    # message      = threadable.messages.latest
    # conversation = expected_organization.conversations.latest

    # expect( incoming_email.message      ).to eq message
    # expect( incoming_email.conversation ).to eq conversation
    # expect( message.conversation        ).to eq conversation

    # if expect_conversation_to_be_a_task
    #   expect( conversation ).to be_task
    #   if expect_task_to_be_done
    #     expect( conversation ).to be_done
    #   else
    #     expect( conversation ).to_not be_done
    #   end
    # else
    #   expect( conversation ).to_not be_task
    # end

    # expect( incoming_email.params['attachment-count'] ).to be_nil
    # expect( incoming_email.params['attachment-1']     ).to be_nil
    # expect( incoming_email.params['attachment-2']     ).to be_nil
    # expect( incoming_email.params['attachment-3']     ).to be_nil

    # expect( message.organization      ).to eq expected_organization
    # expect( message.conversation      ).to eq expected_conversation
    # expect( message.message_id_header ).to eq message_id
    # expect( message.to_header         ).to eq to
    # expect( message.cc_header         ).to eq cc
    # expect( message.date_header       ).to eq date.rfc2822
    # expect( message.references_header ).to eq references
    # expect( message.subject           ).to eq expected_message_subject
    # expect( message.body_plain        ).to eq expected_message_body_plain
    # expect( message.body_html         ).to eq expected_message_body_html
    # expect( message.stripped_html     ).to eq expected_message_stripped_html
    # expect( message.stripped_plain    ).to eq expected_message_stripped_text

    # expect( message.conversation.groups.all.map(&:name) ).to match_array expected_groups

    # incoming_email_attachments = incoming_email.attachments.all.map do |attachment|
    #   [attachment.filename, attachment.mimetype, attachment.content]
    # end.to_set

    # expect( sent_emails.map(&:smtp_envelope_to).flatten ).to match_array expected_email_recipients

    # if result == :duplicate
    #   expect( incoming_email.params['attachment-count'] ).to be_nil
    #   expect( incoming_email.params['attachment-1']     ).to be_nil
    #   expect( incoming_email.params['attachment-2']     ).to be_nil
    #   expect( incoming_email.params['attachment-3']     ).to be_nil
    #   expect( incoming_email_attachments ).to be_empty
    #   return
    # end

    # # only validating delivered messages beyond this point

    # expect(incoming_email_attachments).to eq posted_attachments
    # if check_attachments
    #   expect( message.attachments.all.to_set ).to eq incoming_email.attachments.all.to_set
    # end

    # recipients = message.recipients.all.reject do |user|
    #   message.creator.same_user?(user) if message.creator
    # end

    # recipients.each do |recipient|
    #   expect(message.sent_to?(recipient)).to be_true
    #   expect(message.sent_email(recipient).relayed?).to be_true
    # end

    # recipient_email_addresses = recipients.map(&:email_address)
    # expected_emails_count = recipient_email_addresses.length
    # expect(sent_emails.count).to eq expected_emails_count


    # sent_emails.each do |email|
    #   expect( email.from ).to eq(
    #     (message.creator && email.smtp_envelope_to.include?(message.creator.email_address) ) ?
    #     [recipient] : [ExtractEmailAddresses.call(from).first]
    #   )
    #   expect( email.message_id                      ).to eq message_id[1..-2]
    #   expect( email.header[:References].to_s        ).to eq references
    #   expect( email.date.in_time_zone.rfc2822       ).to eq date.rfc2822
    #   if expected_sent_email_to.is_a? Set
    #     expect( email.to.to_set                     ).to eq expected_sent_email_to
    #   else
    #     expect( email.to                            ).to eq expected_sent_email_to
    #   end
    #   expect( email.header[:Cc].to_s                ).to eq expected_sent_email_cc
    #   expect( email.smtp_envelope_to.length         ).to eq 1
    #   expect( recipient_email_addresses             ).to include email.smtp_envelope_to.first
    #   expect( email.smtp_envelope_from              ).to eq expected_sent_email_smtp_envelope_from
    #   expect( email.subject                         ).to eq expected_sent_email_subject
    #   expect( email.html_content                    ).to include expected_sent_email_body_html
    #   expect( email.text_content                    ).to include expected_sent_email_body_plain
    #   expect( email.header['Reply-To'].to_s         ).to eq expected_sent_email_reply_to
    #   expect( email.header['List-ID'].to_s          ).to eq expected_sent_email_list_id
    #   expect( email.header['List-Archive'].to_s     ).to eq expected_sent_email_list_archive
    #   expect( email.header['List-Unsubscribe'].to_s ).to be_present
    #   expect( email.header['List-Post'].to_s        ).to eq expected_sent_email_list_post

    #   content_ids = JSON.parse(params["content-id-map"])
    #   email.mail_message.attachments.each do |sent_attachment|
    #     expect( content_ids ).to have_key sent_attachment.content_id
    #   end
    # end
  end


  # let(:posted_attachments) do
  #   attachments.map do |attachment|
  #     [attachment.original_filename, attachment.content_type, File.read(attachment.path)]
  #   end.to_set
  # end

  # let(:check_attachments) { true }

  # # default incoming email params

  # let(:subject)      { 'OMG guys I love threadable!' }
  # let(:message_id)   { '<CABQbZc9oj=-_0WwB2eZKq6xLwaM2-b_X2rdjuC5qt-NFi1gDHw@mail.gmail.com>' }

  # let(:from)         { 'Yan Hzu <yan@ucsd.example.com>' }
  # let(:envelope_from){ '<yan@ucsd.example.com>' }
  # let(:sender)       { 'yan@ucsd.example.com' }

  # let(:recipient)    { 'raceteam@127.0.0.1' }
  # let(:to)           { 'UCSD Electric Racing <raceteam@127.0.0.1>' }
  # let(:cc)           { '' }

  # let(:content_type) { 'multipart/alternative; boundary="089e0158ba9ec5cbb704eb3fc74e"' }
  # let(:date)         { Time.parse(14.days.ago.to_s).in_time_zone } # round off milliseconds

  # let(:in_reply_to)  { '' }
  # let(:references)   { '' }

  # let(:body_html){
  #   %(<p>I think we should build it out of fiberglass and duck tape.\n</p>\n)+
  #   %(<blockquote>)+
  #   %(I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
  #   %(make the body out of carbon or buy a giant boat and cut it up or whatever.)+
  #   %(</blockquote>)
  # }
  # let(:body_plain){
  #   %(I think we should build it out of fiberglass and duck tape.\n\n)+
  #   %(> I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
  #   %(> make the body out of carbon or buy a giant boat and cut it up or whatever.)
  # }
  # let(:stripped_html){
  #   %(<p>I think we should build it out of fiberglass and duck tape.\n</p>)
  # }
  # let(:stripped_text){
  #   %(I think we should build it out of fiberglass and duck tape.)
  # }

  # let :attachments do
  #   [
  #     RSpec::Support::Attachments.uploaded_file("some.gif", 'image/gif',  true),
  #     RSpec::Support::Attachments.uploaded_file("some.jpg", 'image/jpeg', true),
  #     RSpec::Support::Attachments.uploaded_file("some.txt", 'text/plain', false),
  #   ]
  # end

  # # default expected values for the default incoming email params above

  # let(:expected_parent_message)                { nil }
  # let(:expected_conversation)                  { expected_organization.conversations.latest }
  # let(:expected_creator)                       { threadable.users.find_by_email_address('yan@ucsd.example.com') }
  # let(:expected_organization)                  { threadable.organizations.find_by_slug!('raceteam') }
  # let(:expected_conversation_subject)          { 'OMG guys I love threadable!' }
  # let(:expected_message_subject)               { 'OMG guys I love threadable!' }
  # let(:expected_message_body_html)             { body_html }
  # let(:expected_message_body_plain)            { body_plain }
  # let(:expected_message_stripped_html)         { stripped_html }
  # let(:expected_message_stripped_text)         { stripped_text }
  # let(:expect_conversation_to_be_a_task)       { false }
  # let(:expect_task_to_be_done)                 { false }
  # let(:expected_email_recipients)              { ["alice@ucsd.example.com", "tom@ucsd.example.com", "bethany@ucsd.example.com", "nadya@ucsd.example.com", "bob@ucsd.example.com"] }
  # let(:expected_sent_email_to)                 { ['raceteam@127.0.0.1'] }
  # let(:expected_sent_email_cc)                 { '' }
  # let(:expected_sent_email_subject)            { "#{expected_conversation.subject_tag} OMG guys I love threadable!" }
  # let(:expected_sent_email_smtp_envelope_from) { 'raceteam@127.0.0.1' }
  # let(:expected_sent_email_reply_to)           { 'UCSD Electric Racing <raceteam@127.0.0.1>' }
  # let(:expected_sent_email_list_id)            { expected_conversation.list_id }
  # let(:expected_sent_email_list_archive)       { "<#{conversations_url(expected_organization, 'my')}>" }
  # let(:expected_sent_email_list_post)          { "<mailto:#{expected_conversation.list_post_email_address}>, <#{compose_conversation_url(expected_organization, 'my')}>" }
  # let(:expected_sent_email_body_html)          { body_html }
  # let(:expected_sent_email_body_plain)         { body_plain }
  # let(:expected_groups)                        { [] }

  def munge params
    # we are not testing these things here, so set them in a way that will allow the message to otherwise work.
    params["timestamp"] = Time.now.to_i.to_s
    params["token"]     = SecureRandom.uuid
    params["signature"] = MailgunSignature.encode(params["timestamp"], params["token"])
    params["From"]      = proxy_from
    params["from"]      = proxy_from
    params["recipient"] = proxy_recipient

    if attachments
      content_id_map = {}
      params['attachment-count'] = attachments.count.to_s
      attachments.each_with_index do |attachment, index|
        name = "attachment-#{index+1}"
        contentid = "<#{attachment.original_filename.gsub(/\W/, '')}contentid>"
        content_id_map[contentid] = name
        params[name] = attachment
      end
      params["content-id-map"] = content_id_map.to_json
    end

    params
  end

  context "with a broken message from zac at apportable" do
    let(:proxy_from) { 'alice@ucsd.example.com' }
    let(:proxy_recipient) { 'raceteam@localhost' }

    let :attachments do
      [
        RSpec::Support::Attachments.uploaded_file('fixes]""().eml', "message/rfc822", false),
        RSpec::Support::Attachments.uploaded_file('smime.p7s', "application/octet-stream", true),
      ]
    end

    let(:params) { munge(
      "Cc"=>"Christina Kelly <ckelly@apportable.com>, All Apportable <all@apportable.com>",
      "Content-Type"=>"multipart/signed; boundary=\"Apple-Mail=_579A518A-A862-4D14-B1B0-CF47EC436B9A\"; protocol=\"application/pkcs7-signature\"; micalg=\"sha1\"",
      "Date"=>"Fri, 21 Feb 2014 20:24:43 -0800",
      "From"=>"Zac Bowling <zac@apportable.com>",
      "In-Reply-To"=>"<CALO0tS2Ri7bERtTOccuoep7hUxFYWWE0nxMbMNXCmM3ROZKC9w@mail.gmail.com>",
      "List-Archive"=>"<http://groups.google.com/a/apportable.com/group/all/>",
      "List-Help"=>"<http://support.google.com/a/apportable.com/bin/topic.py?topic=25838>, <mailto:all+help@apportable.com>",
      "List-Id"=>"<all.apportable.com>",
      "List-Post"=>"<http://groups.google.com/a/apportable.com/group/all/post>, <mailto:all@apportable.com>",
      "List-Unsubscribe"=>"<http://groups.google.com/a/apportable.com/group/all/subscribe>, <mailto:googlegroups-manage+1093059115132+unsubscribe@googlegroups.com>",
      "Mailing-List"=>"list all@apportable.com; contact all+owners@apportable.com",
      "Message-Id"=>"<3E0F5175-63B3-4BE9-A697-B211879161C2@apportable.com>",
      "Mime-Version"=>"1.0 (Mac OS X Mail 7.1 \\(1827\\))",
      "Precedence"=>"list",
      "Received"=>"from [10.0.1.13] ([199.87.83.38]) by mx.google.com with ESMTPSA id xf3sm26677498pbc.30.2014.02.21.20.25.14 for <multiple recipients> (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128); Fri, 21 Feb 2014 20:25:14 -0800 (PST)",
      "Received-Spf"=>"softfail (google.com: domain of transitioning zac@apportable.com does not designate 209.85.220.52 as permitted sender) client-ip=209.85.220.52;",
      "References"=>"<CAOwgpSLw3g6mUrS_xuXt9L3fe3Qx5Wi59SbG1LXc+Ws7vjih5A@mail.gmail.com> <B47249F9-8718-4C6E-B193-6B1C1F4C42D6@apportable.com> <CAOwgpS+vFgLx6o0EQydNtj-wQ09ozs81zV0N_QJHsS7RzLfTYw@mail.gmail.com> <CALO0tS2Ri7bERtTOccuoep7hUxFYWWE0nxMbMNXCmM3ROZKC9w@mail.gmail.com>",
      "Subject"=>"Re: Threadable for email lists: Everyone's Doing It (and Why)",
      "To"=>"Nicole Aptekar <nicole@other.io>",
      "X-Beenthere"=>"all@apportable.com",
      "X-Envelope-From"=>"<all+bncBDVOVGXZN4IKZTNATACRUBCHHVQLU@apportable.com>",
      "X-Gm-Message-State"=>"ALoCoQnAuJwU8IcSptyPf4myvRetpUIMmJu9pnKF+C7S2oTLT8+IeTiacVaW8v5iUKcYOfsVpEta",
      "X-Google-Dkim-Signature"=>"v=1; a=rsa-sha256; c=relaxed/relaxed; d=1e100.net; s=20130820; h=x-gm-message-state:content-type:mime-version:subject:from :in-reply-to:date:cc:message-id:references:to:x-original-sender :x-original-authentication-results:precedence:mailing-list:list-id :list-post:list-help:list-archive:list-unsubscribe; bh=65PeBDxO/TPablep/LdO8gzPNYwXFTx/ubdb3U7touQ=; b=Q+PX6Xf/FGoECxVNwdkLLMcaqrYUvxNZgDmTEmxtC2c6aBJNUhf7aHOCC2q1gS8mIh gtNAb6CbYiqEOAr0dFbeFHJ55e8JTyl7Yi6jNm8Caeb/Y+rQJy6mTvtLPzRXeyicFht7 KQycDc5ZofYLjlyc4taxUtYh+HFQ7o8zhC0viEk2smhHVNfzBVTtHYP0ul2TS8Ihkqkt 7VB6KeQfm2td4WaxXw38ng7ryohjvJH5o9pcUhq4C+/boAhf0Fko60SpW/v0sf/CWHuB Oy60qoEKS83SZRdxTka/j6VTdz++3qUlmQzWE1sGxCPXToE4mS5a8qLXW+MhGJyvlBvh FVPw==",
      "X-Google-Group-Id"=>"1093059115132",
      "X-Mailer"=>"Apple Mail (2.1827)",
      "X-Mailgun-Incoming"=>"Yes",
      "X-Mailgun-Sflag"=>"No",
      "X-Mailgun-Spf"=>"SoftFail",
      "X-Mailgun-Sscore"=>"0.3",
      "X-Original-Authentication-Results"=>"mx.google.com; spf=softfail (google.com: domain of transitioning zac@apportable.com does not designate 209.85.220.52 as permitted sender) smtp.mail=zac@apportable.com",
      "X-Original-Sender"=>"zac@apportable.com",
      "X-Received"=>"by 10.68.171.193 with SMTP id aw1mr12982219pbc.117.1393043115833; Fri, 21 Feb 2014 20:25:15 -0800 (PST)",
      "body-html"=>"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html charset=us-ascii\"></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\"><div>Here you go!</div></body></html><html><head><meta http-equiv=\"Content-Type\" content=\"text/html charset=utf-8\"></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\"><div><br></div><div><br><div><div>On Feb 21, 2014, at 8:21 PM, Nicole Aptekar &lt;<a href=\"mailto:nicole@other.io\">nicole@other.io</a>&gt; wrote:</div><br class=\"Apple-interchange-newline\"><blockquote type=\"cite\"><div dir=\"ltr\">We can also probably detect that code is present and Do The Right Thing there. Probably even with highlighting and such. Can you forward me one of those mails?<div><br></div><div>Thanks!</div><div><br></div>\r\n\r\n<div>~Nicole</div></div><div class=\"gmail_extra\"><br><br><div class=\"gmail_quote\">On Fri, Feb 21, 2014 at 8:17 PM, Christina Kelly <span dir=\"ltr\">&lt;<a href=\"mailto:ckelly@apportable.com\" target=\"_blank\">ckelly@apportable.com</a>&gt;</span> wrote:<br>\r\n\r\n<blockquote class=\"gmail_quote\" style=\"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex\"><div dir=\"ltr\">I can move the cr@ list back to google groups for now. &nbsp;Adding Nicole.</div><div class=\"gmail_extra\"><br>\r\n\r\n<br><div class=\"gmail_quote\">On Fri, Feb 21, 2014 at 8:06 PM, Zac Bowling <span dir=\"ltr\">&lt;<a href=\"mailto:zac@apportable.com\" target=\"_blank\">zac@apportable.com</a>&gt;</span> wrote:<br>\r\n\r\n<blockquote class=\"gmail_quote\" style=\"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex\"><div style=\"word-wrap:break-word\"><div>Fantastic.</div><div><br></div>My only objection is the cr list. Threadable converts the emails from plain text to HTML breaks my ability to read the code easier my fixed width font I use on plain text.<div>\r\n\r\n\r\n\r\n<br></div><div>Is there a way I can get the only CR emails directly and not have that on threadable? Or maybe have threadable send plain text?</div><span><font color=\"#888888\"><div><br></div><div>Zac</div>\r\n</font></span><div><div class=\"h5\">\r\n<div><br><div><div>On Feb 21, 2014, at 4:11 PM, Christina Kelly &lt;<a href=\"mailto:ckelly@apportable.com\" target=\"_blank\">ckelly@apportable.com</a>&gt; wrote:</div><br><blockquote type=\"cite\"><div dir=\"ltr\">\r\n\r\nHi all,<div><br></div><div>In an effort to make email groups more transparent AND try out awesomely designed new software by Nicole's startup, we've just moved a bunch more email lists over to Threadable. &nbsp;Here is a list of the old lists and what they have turned into. &nbsp;Update your address books accordingly! &nbsp;Note that emailing the old list address will forward to the new one, for now.</div>\r\n\r\n\r\n\r\n\r\n\r\n<div><ul><li><a href=\"mailto:all@apportable.com\" target=\"_blank\">all@apportable.com</a> --&gt; <a href=\"mailto:apportable%2Ball@threadable.com\" target=\"_blank\">apportable+all@threadable.com</a><br></li><li><a href=\"mailto:social@apportable.com\" target=\"_blank\">social@apportable.com</a> --&gt; <a href=\"mailto:apportable%2Bsocial@threadable.com\" target=\"_blank\">apportable+social@threadable.com</a><br>\r\n\r\n\r\n\r\n\r\n\r\n</li><li><a href=\"mailto:devs@apportable.com\" target=\"_blank\">devs@apportable.com</a> --&gt; <a href=\"mailto:apportable%2Bdevs@threadable.com\" target=\"_blank\">apportable+devs@threadable.com</a></li></ul></div><div>One of the advantages of Threadable is that it's really easy to create and subscribe to groups (what Threadable calls email lists)! &nbsp;Here are a few new groups which you can selectively subscribe/unsubscribe to as you like (devs have been pre-subscribed to CR and buildbot groups):</div>\r\n\r\n\r\n\r\n\r\n\r\n<div><ul><li><a href=\"mailto:cr@apportable.com\" target=\"_blank\">cr@apportable.com</a> --&gt; <a href=\"mailto:apportable%2Bcr@threadable.com\" target=\"_blank\">apportable+cr@threadable.com</a> [NOTE: No longer forwards to devs@]<br>\r\n\r\n\r\n\r\n</li><li>build break notifications --&gt; <a href=\"mailto:apportable%2Bbuildbot@threadable.com\" target=\"_blank\">apportable+buildbot@threadable.com</a> [NOTE: Notifications are no longer automatically sent to devs@]<br>\r\n\r\n</li><li>Wiki notifications --&gt; <a href=\"mailto:apportable%2Bwiki@threadable.com\" target=\"_blank\">apportable+wiki@threadable.com</a> [NOTE: You must now opt in to get notifications]<br></li></ul><div>Want to create your own group and invite a bunch of people to it? &nbsp;Go right ahead! &nbsp;If you'd like to convert an existing @<a href=\"http://apportable.com/\" target=\"_blank\">apportable.com</a> list to Threadable, let me know.</div>\r\n\r\n\r\n\r\n\r\n\r\n<div><br></div><div>If you haven't tried the web interface yet, check it out! &nbsp;You'll be able to see messages in all the different groups, create your own, and subscribe/unsubscribe as you like. &nbsp;Go to&nbsp;<a href=\"https://threadable.com/apportable\" target=\"_blank\">https://threadable.com/apportable</a> - here's a preview of what it looks like:&nbsp;<a href=\"http://monosnap.com/image/OcznOwMAeciZB3Naxh553DDfg41UOZ\" target=\"_blank\">http://monosnap.com/image/OcznOwMAeciZB3Naxh553DDfg41UOZ</a>.</div>\r\n\r\n\r\n\r\n\r\n\r\n</div><div><br></div><div>And, here is a bunch of words from Nicole herself describing Threadable's features!</div><div><br></div><div>~~~~~~~~~</div><div><br></div><div><div style=\"font-family:arial,sans-serif;font-size:13px;color:rgb(68,68,68);line-height:20px\">\r\n\r\n\r\n\r\n\r\n\r\n<font size=\"4\">Understanding Threadable</font></div><div style=\"font-family:arial,sans-serif;font-size:13px;color:rgb(68,68,68);line-height:20px\"><br></div><span style=\"font-family:arial,sans-serif;font-size:13px\">Mailing lists provide you with a single email address that you can use to communicate with the rest of your group. In general, the more people you add, the more useful the list becomes, as you are enabling your members to communicate and dynamically self-organize around issues that matter to them. But with traditional mailing lists this can also result in a lot of traffic, which can become distracting.</span><br style=\"font-family:arial,sans-serif;font-size:13px\">\r\n\r\n\r\n\r\n\r\n\r\n<br style=\"font-family:arial,sans-serif;font-size:13px\"><span style=\"font-family:arial,sans-serif;font-size:13px\">Threadable solves this problem in several ways.</span><br style=\"font-family:arial,sans-serif;font-size:13px\">\r\n\r\n\r\n\r\n\r\n\r\n<br style=\"font-family:arial,sans-serif;font-size:13px\"><span style=\"font-family:arial,sans-serif;font-size:13px\">First, we allow any member to easily mute any conversation. Once muted, new replies to that thread will no longer appear in that user’s inbox.</span><br style=\"font-family:arial,sans-serif;font-size:13px\">\r\n\r\n\r\n\r\n\r\n\r\n<br style=\"font-family:arial,sans-serif;font-size:13px\"><span style=\"font-family:arial,sans-serif;font-size:13px\">Second, Threadable users can easily assign conversations to specific groups of recipients, replacing the need for both convoluted and fragile reply-to-all chains, and the trouble of setting up brand new lists. (more about this below)</span><div style=\"font-family:arial,sans-serif;font-size:13px\">\r\n\r\n\r\n\r\n\r\n\r\n<br><div style=\"color:rgb(68,68,68);line-height:20px\"><span style=\"font-size:large\">Conversations &amp; Tasks</span><br></div><div style=\"color:rgb(68,68,68);line-height:20px\"><br></div>Any email you send to&nbsp;<a href=\"mailto:apportable@threadable.com\" target=\"_blank\">apportable@threadable.com</a>&nbsp;will be sent to all members of your organization, just like a traditional mailing list.<br>\r\n\r\n\r\n\r\n\r\n\r\n<br>To create a task, either use the \"New Task\" button in any Threadable email, or send an email to&nbsp;<a href=\"mailto:apportable%2Btask@threadable.com\" target=\"_blank\">apportable+task@threadable.com</a>&nbsp;with the name of the task in the subject line, and any description or discussion about that task in the message body.<br>\r\n\r\n\r\n\r\n\r\n\r\n<br>In Threadable, a task is just an email thread, but with some additional information, such as who it is assigned to, and whether or not it has been completed. This makes it easy for everyone to see and talk about their shared tasks.<div style=\"color:rgb(68,68,68);line-height:20px\">\r\n\r\n\r\n\r\n\r\n\r\n<br></div><div style=\"color:rgb(68,68,68);line-height:20px\"><font size=\"4\">Mail Buttons &amp; Mail Commands</font></div><div style=\"color:rgb(68,68,68);line-height:20px\"><font size=\"4\"><br></font></div>To interact with Threadable from email, just click the buttons that appear at the top of each message, or just type one of the commands below:<div style=\"color:rgb(68,68,68);line-height:20px\">\r\n\r\n\r\n\r\n\r\n\r\n<br></div><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><div style=\"color:rgb(68,68,68);line-height:20px\"><div style=\"color:rgb(34,34,34);line-height:normal\"><b>&amp;done</b>&nbsp;(marks a task as done)</div>\r\n\r\n\r\n\r\n\r\n\r\n</div><div style=\"color:rgb(68,68,68);line-height:20px\"><div style=\"color:rgb(34,34,34);line-height:normal\"><b>&amp;undone</b>&nbsp;(marks a task as not done)</div></div><div style=\"color:rgb(68,68,68);line-height:20px\"><div style=\"color:rgb(34,34,34);line-height:normal\">\r\n\r\n\r\n\r\n\r\n\r\n<b>&amp;add</b>&nbsp;Nicole Aptekar (adds me to a task: you can use a full name or email address of anyone in your organization)</div></div><div style=\"color:rgb(68,68,68);line-height:20px\"><div style=\"color:rgb(34,34,34);line-height:normal\">\r\n\r\n\r\n\r\n\r\n\r\n<b>&amp;remove</b>&nbsp;<a href=\"mailto:nicole@other.io\" target=\"_blank\"><span style=\"color:rgb(34,34,34)\">nicole@other.io</span></a>&nbsp;(removes me from a task)</div></div><div style=\"color:rgb(68,68,68);line-height:20px\">\r\n\r\n<div style=\"color:rgb(34,34,34);line-height:normal\"><b>&amp;mute</b>&nbsp;(mutes the conversation)</div></div></blockquote><div style=\"color:rgb(68,68,68);line-height:20px\"><div style=\"color:rgb(34,34,34);line-height:normal\">\r\n\r\n\r\n\r\n\r\n<br>\r\n</div></div>(Note that, in order to be recognized, commands must be on the first line of your new email. But we plan to make them work anywhere within an email soon.)<div style=\"color:rgb(68,68,68);line-height:20px\"><br>\r\n\r\n\r\n\r\n\r\n</div>\r\n<div style=\"color:rgb(68,68,68);line-height:20px\"><font size=\"4\">Groups</font></div><div><div style=\"color:rgb(68,68,68);line-height:20px\"><br></div>Groups let you divide your organization into smaller pieces, and categorize your tasks and conversations. Each group can have a different subset of members subscribed to it, and each has its own email address, in the format:&nbsp;<a href=\"mailto:organization%2Bgroup@threadable.com\" target=\"_blank\">organization+group@threadable.com</a>.<div style=\"color:rgb(68,68,68);line-height:20px\">\r\n\r\n\r\n\r\n\r\n\r\n<br></div><div><div>Here's an example of how to use groups: Let's say your organization is ten people making an indie film. After about a week, your conversations and tasks look like:</div><div><br></div><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\">\r\n\r\n\r\n\r\n\r\n\r\n<div>✔︎ Get a new camera</div><div>Let's find a makeup artist</div><div>I know a warehouse where we can film</div><div>✔︎ Call Ernie's dad about filming in his treehouse</div><div>Which beach is best for the beach scene?</div>\r\n\r\n\r\n\r\n\r\n\r\n</blockquote><div><br></div><div><font face=\"arial, sans-serif\">It looks like ther</font>e's a lot of activity around locations. Three of the group members, Ernie, Sarah, and Ty, are the ones doing all the location scouting. Marsha, the videographer, is really busy with a couple other projects and doesn't care about locations.<br>\r\n\r\n\r\n\r\n\r\n\r\n<br>At any time, you can log into Threadable and move the location scouting stuff into a new group, called +location. Put Ernie, Sarah, and Ty in that group, and you're done! Marsha no longer gets emails about locations, but she can still see them on the web if she needs to. The flow of the existing conversations isn't interrupted, so when Ernie writes back to the beach thread, Sarah and Ty still get his message. If they want to start new conversations about location, they can email&nbsp;<a href=\"mailto:indiemovie%2Blocation@threadable.com\" target=\"_blank\">indiemovie+location@threadable.com</a>. Easy!<br>\r\n\r\n\r\n\r\n\r\n\r\n<br>We think this is a powerful layer of flexibility that has never before been a part of the group email experience. I’m super curious about how it works for you.</div></div></div></div></div><div><br></div><div><br></div>\r\n\r\n\r\n\r\n\r\n\r\n<div><br clear=\"all\"><div><br></div>-- <br>Christina<div>The Apportable Team</div>\r\n</div></div>\r\n</blockquote></div><br></div></div></div></div></blockquote></div><div><div class=\"h5\"><br><br clear=\"all\"><div><br></div>-- <br>Christina<div>The Apportable Team</div>\r\n</div></div></div>\r\n</blockquote></div><br></div>\r\n</blockquote></div><br></div></body></html>",
      "body-plain"=>"Here you go!\r\n\r\n\r\n\r\nOn Feb 21, 2014, at 8:21 PM, Nicole Aptekar <nicole@other.io> wrote:\r\n\r\n> We can also probably detect that code is present and Do The Right Thing there. Probably even with highlighting and such. Can you forward me one of those mails?\r\n> \r\n> Thanks!\r\n> \r\n> ~Nicole\r\n> \r\n> \r\n> On Fri, Feb 21, 2014 at 8:17 PM, Christina Kelly <ckelly@apportable.com> wrote:\r\n> I can move the cr@ list back to google groups for now.  Adding Nicole.\r\n> \r\n> \r\n> On Fri, Feb 21, 2014 at 8:06 PM, Zac Bowling <zac@apportable.com> wrote:\r\n> Fantastic.\r\n> \r\n> My only objection is the cr list. Threadable converts the emails from plain text to HTML breaks my ability to read the code easier my fixed width font I use on plain text.\r\n> \r\n> Is there a way I can get the only CR emails directly and not have that on threadable? Or maybe have threadable send plain text?\r\n> \r\n> Zac\r\n> \r\n> On Feb 21, 2014, at 4:11 PM, Christina Kelly <ckelly@apportable.com> wrote:\r\n> \r\n>> Hi all,\r\n>> \r\n>> In an effort to make email groups more transparent AND try out awesomely designed new software by Nicole's startup, we've just moved a bunch more email lists over to Threadable.  Here is a list of the old lists and what they have turned into.  Update your address books accordingly!  Note that emailing the old list address will forward to the new one, for now.\r\n>> all@apportable.com --> apportable+all@threadable.com\r\n>> social@apportable.com --> apportable+social@threadable.com\r\n>> devs@apportable.com --> apportable+devs@threadable.com\r\n>> One of the advantages of Threadable is that it's really easy to create and subscribe to groups (what Threadable calls email lists)!  Here are a few new groups which you can selectively subscribe/unsubscribe to as you like (devs have been pre-subscribed to CR and buildbot groups):\r\n>> cr@apportable.com --> apportable+cr@threadable.com [NOTE: No longer forwards to devs@]\r\n>> build break notifications --> apportable+buildbot@threadable.com [NOTE: Notifications are no longer automatically sent to devs@]\r\n>> Wiki notifications --> apportable+wiki@threadable.com [NOTE: You must now opt in to get notifications]\r\n>> Want to create your own group and invite a bunch of people to it?  Go right ahead!  If you'd like to convert an existing @apportable.com list to Threadable, let me know.\r\n>> \r\n>> If you haven't tried the web interface yet, check it out!  You'll be able to see messages in all the different groups, create your own, and subscribe/unsubscribe as you like.  Go to https://threadable.com/apportable - here's a preview of what it looks like: http://monosnap.com/image/OcznOwMAeciZB3Naxh553DDfg41UOZ.\r\n>> \r\n>> And, here is a bunch of words from Nicole herself describing Threadable's features!\r\n>> \r\n>> ~~~~~~~~~\r\n>> \r\n>> Understanding Threadable\r\n>> \r\n>> Mailing lists provide you with a single email address that you can use to communicate with the rest of your group. In general, the more people you add, the more useful the list becomes, as you are enabling your members to communicate and dynamically self-organize around issues that matter to them. But with traditional mailing lists this can also result in a lot of traffic, which can become distracting.\r\n>> \r\n>> Threadable solves this problem in several ways.\r\n>> \r\n>> First, we allow any member to easily mute any conversation. Once muted, new replies to that thread will no longer appear in that user’s inbox.\r\n>> \r\n>> Second, Threadable users can easily assign conversations to specific groups of recipients, replacing the need for both convoluted and fragile reply-to-all chains, and the trouble of setting up brand new lists. (more about this below)\r\n>> \r\n>> Conversations & Tasks\r\n>> \r\n>> Any email you send to apportable@threadable.com will be sent to all members of your organization, just like a traditional mailing list.\r\n>> \r\n>> To create a task, either use the \"New Task\" button in any Threadable email, or send an email to apportable+task@threadable.com with the name of the task in the subject line, and any description or discussion about that task in the message body.\r\n>> \r\n>> In Threadable, a task is just an email thread, but with some additional information, such as who it is assigned to, and whether or not it has been completed. This makes it easy for everyone to see and talk about their shared tasks.\r\n>> \r\n>> Mail Buttons & Mail Commands\r\n>> \r\n>> To interact with Threadable from email, just click the buttons that appear at the top of each message, or just type one of the commands below:\r\n>> \r\n>> &done (marks a task as done)\r\n>> &undone (marks a task as not done)\r\n>> &add Nicole Aptekar (adds me to a task: you can use a full name or email address of anyone in your organization)\r\n>> &remove nicole@other.io (removes me from a task)\r\n>> &mute (mutes the conversation)\r\n>> \r\n>> (Note that, in order to be recognized, commands must be on the first line of your new email. But we plan to make them work anywhere within an email soon.)\r\n>> \r\n>> Groups\r\n>> \r\n>> Groups let you divide your organization into smaller pieces, and categorize your tasks and conversations. Each group can have a different subset of members subscribed to it, and each has its own email address, in the format: organization+group@threadable.com.\r\n>> \r\n>> Here's an example of how to use groups: Let's say your organization is ten people making an indie film. After about a week, your conversations and tasks look like:\r\n>> \r\n>> ✔︎ Get a new camera\r\n>> Let's find a makeup artist\r\n>> I know a warehouse where we can film\r\n>> ✔︎ Call Ernie's dad about filming in his treehouse\r\n>> Which beach is best for the beach scene?\r\n>> \r\n>> It looks like there's a lot of activity around locations. Three of the group members, Ernie, Sarah, and Ty, are the ones doing all the location scouting. Marsha, the videographer, is really busy with a couple other projects and doesn't care about locations.\r\n>> \r\n>> At any time, you can log into Threadable and move the location scouting stuff into a new group, called +location. Put Ernie, Sarah, and Ty in that group, and you're done! Marsha no longer gets emails about locations, but she can still see them on the web if she needs to. The flow of the existing conversations isn't interrupted, so when Ernie writes back to the beach thread, Sarah and Ty still get his message. If they want to start new conversations about location, they can email indiemovie+location@threadable.com. Easy!\r\n>> \r\n>> We think this is a powerful layer of flexibility that has never before been a part of the group email experience. I’m super curious about how it works for you.\r\n>> \r\n>> \r\n>> \r\n>> \r\n>> -- \r\n>> Christina\r\n>> The Apportable Team\r\n> \r\n> \r\n> \r\n> \r\n> -- \r\n> Christina\r\n> The Apportable Team\r\n> \r\n\r\n",
      "from"=>"Zac Bowling <zac@apportable.com>",
      "message-headers"=>"[[\"Received\", \"by luna.mailgun.net with SMTP mgrt 4524433; Sat, 22 Feb 2014 04:25:19 +0000\"], [\"X-Envelope-From\", \"<all+bncBDVOVGXZN4IKZTNATACRUBCHHVQLU@apportable.com>\"], [\"Received\", \"from mail-yk0-f197.google.com (mail-yk0-f197.google.com [209.85.160.197]) by mxa.mailgun.org with ESMTP id 530826ac.7f01f63eda30-in3; Sat, 22 Feb 2014 04:25:16 -0000 (UTC)\"], [\"Received\", \"by mail-yk0-f197.google.com with SMTP id 142sf12845764ykq.0 for <apportable--all@threadable.com>; Fri, 21 Feb 2014 20:25:16 -0800 (PST)\"], [\"X-Google-Dkim-Signature\", \"v=1; a=rsa-sha256; c=relaxed/relaxed; d=1e100.net; s=20130820; h=x-gm-message-state:content-type:mime-version:subject:from :in-reply-to:date:cc:message-id:references:to:x-original-sender :x-original-authentication-results:precedence:mailing-list:list-id :list-post:list-help:list-archive:list-unsubscribe; bh=65PeBDxO/TPablep/LdO8gzPNYwXFTx/ubdb3U7touQ=; b=Q+PX6Xf/FGoECxVNwdkLLMcaqrYUvxNZgDmTEmxtC2c6aBJNUhf7aHOCC2q1gS8mIh gtNAb6CbYiqEOAr0dFbeFHJ55e8JTyl7Yi6jNm8Caeb/Y+rQJy6mTvtLPzRXeyicFht7 KQycDc5ZofYLjlyc4taxUtYh+HFQ7o8zhC0viEk2smhHVNfzBVTtHYP0ul2TS8Ihkqkt 7VB6KeQfm2td4WaxXw38ng7ryohjvJH5o9pcUhq4C+/boAhf0Fko60SpW/v0sf/CWHuB Oy60qoEKS83SZRdxTka/j6VTdz++3qUlmQzWE1sGxCPXToE4mS5a8qLXW+MhGJyvlBvh FVPw==\"], [\"X-Gm-Message-State\", \"ALoCoQnAuJwU8IcSptyPf4myvRetpUIMmJu9pnKF+C7S2oTLT8+IeTiacVaW8v5iUKcYOfsVpEta\"], [\"X-Received\", \"by 10.224.55.19 with SMTP id s19mr5372919qag.0.1393043116255; Fri, 21 Feb 2014 20:25:16 -0800 (PST)\"], [\"X-Beenthere\", \"all@apportable.com\"], [\"Received\", \"by 10.50.66.176 with SMTP id g16ls871946igt.9.canary; Fri, 21 Feb 2014 20:25:16 -0800 (PST)\"], [\"X-Received\", \"by 10.68.131.100 with SMTP id ol4mr13052163pbb.134.1393043116034; Fri, 21 Feb 2014 20:25:16 -0800 (PST)\"], [\"Received\", \"from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52]) by mx.google.com with ESMTPS id gn5si1114727pbc.206.2014.02.21.20.25.16 for <all@apportable.com> (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128); Fri, 21 Feb 2014 20:25:16 -0800 (PST)\"], [\"Received-Spf\", \"softfail (google.com: domain of transitioning zac@apportable.com does not designate 209.85.220.52 as permitted sender) client-ip=209.85.220.52;\"], [\"Received\", \"by mail-pa0-f52.google.com with SMTP id bj1so4282812pad.25 for <all@apportable.com>; Fri, 21 Feb 2014 20:25:16 -0800 (PST)\"], [\"X-Received\", \"by 10.68.171.193 with SMTP id aw1mr12982219pbc.117.1393043115833; Fri, 21 Feb 2014 20:25:15 -0800 (PST)\"], [\"Received\", \"from [10.0.1.13] ([199.87.83.38]) by mx.google.com with ESMTPSA id xf3sm26677498pbc.30.2014.02.21.20.25.14 for <multiple recipients> (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128); Fri, 21 Feb 2014 20:25:14 -0800 (PST)\"], [\"Content-Type\", \"multipart/signed; boundary=\\\"Apple-Mail=_579A518A-A862-4D14-B1B0-CF47EC436B9A\\\"; protocol=\\\"application/pkcs7-signature\\\"; micalg=\\\"sha1\\\"\"], [\"Mime-Version\", \"1.0 (Mac OS X Mail 7.1 \\\\(1827\\\\))\"], [\"Subject\", \"Re: Threadable for email lists: Everyone's Doing It (and Why)\"], [\"From\", \"Zac Bowling <zac@apportable.com>\"], [\"In-Reply-To\", \"<CALO0tS2Ri7bERtTOccuoep7hUxFYWWE0nxMbMNXCmM3ROZKC9w@mail.gmail.com>\"], [\"Date\", \"Fri, 21 Feb 2014 20:24:43 -0800\"], [\"Cc\", \"Christina Kelly <ckelly@apportable.com>, All Apportable <all@apportable.com>\"], [\"Message-Id\", \"<3E0F5175-63B3-4BE9-A697-B211879161C2@apportable.com>\"], [\"References\", \"<CAOwgpSLw3g6mUrS_xuXt9L3fe3Qx5Wi59SbG1LXc+Ws7vjih5A@mail.gmail.com> <B47249F9-8718-4C6E-B193-6B1C1F4C42D6@apportable.com> <CAOwgpS+vFgLx6o0EQydNtj-wQ09ozs81zV0N_QJHsS7RzLfTYw@mail.gmail.com> <CALO0tS2Ri7bERtTOccuoep7hUxFYWWE0nxMbMNXCmM3ROZKC9w@mail.gmail.com>\"], [\"To\", \"Nicole Aptekar <nicole@other.io>\"], [\"X-Mailer\", \"Apple Mail (2.1827)\"], [\"X-Original-Sender\", \"zac@apportable.com\"], [\"X-Original-Authentication-Results\", \"mx.google.com; spf=softfail (google.com: domain of transitioning zac@apportable.com does not designate 209.85.220.52 as permitted sender) smtp.mail=zac@apportable.com\"], [\"Precedence\", \"list\"], [\"Mailing-List\", \"list all@apportable.com; contact all+owners@apportable.com\"], [\"List-Id\", \"<all.apportable.com>\"], [\"X-Google-Group-Id\", \"1093059115132\"], [\"List-Post\", \"<http://groups.google.com/a/apportable.com/group/all/post>, <mailto:all@apportable.com>\"], [\"List-Help\", \"<http://support.google.com/a/apportable.com/bin/topic.py?topic=25838>, <mailto:all+help@apportable.com>\"], [\"List-Archive\", \"<http://groups.google.com/a/apportable.com/group/all/>\"], [\"List-Unsubscribe\", \"<http://groups.google.com/a/apportable.com/group/all/subscribe>, <mailto:googlegroups-manage+1093059115132+unsubscribe@googlegroups.com>\"], [\"X-Mailgun-Incoming\", \"Yes\"], [\"X-Mailgun-Sflag\", \"No\"], [\"X-Mailgun-Sscore\", \"0.3\"], [\"X-Mailgun-Spf\", \"SoftFail\"]]",
      "recipient"=>"apportable--all@threadable.com",
      "sender"=>"all+bncBDVOVGXZN4IKZTNATACRUBCHHVQLU@apportable.com",
      "signature"=>"eac15b63c0cb1bcceae887ab7e7838caf59b8cfb45abb9f07133305daab738dd",
      "stripped-html"=>"<html><head></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\"><div>Here you go!</div></body><html><head></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\"><div><br></div><div><br><div><div></div><br class=\"Apple-interchange-newline\"><blockquote type=\"cite\"><div dir=\"ltr\">We can also probably detect that code is present and Do The Right Thing there. Probably even with highlighting and such. Can you forward me one of those mails?<div><br></div><div>Thanks!</div><div><br></div>\r\n\r\n<div>~Nicole</div></div><div class=\"gmail_extra\"><br><br><br></div>\r\n</blockquote></div><br></div></body></html></html>",
      "stripped-signature"=>"",
      "stripped-text"=>"Here you go!",
      "subject"=>"Re: Threadable for email lists: Everyone's Doing It (and Why)",
      "timestamp"=>"1393043120",
      "token"=>"4ad56wm5c9ccxf0ovmjrbfslvujtmake1uzm0zspk8ev4mfmn3"
    ) }

    it 'delivers a message' do
      validate! :delivered
    end
  end

end
