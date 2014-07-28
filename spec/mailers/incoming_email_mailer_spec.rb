# Encoding: UTF-8
require "spec_helper"

describe IncomingEmailMailer do

  signed_in_as 'bethany@ucsd.example.com'

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
  let(:group) { organization.groups.find_by_email_address_tag('electronics') }

  let :params do
    create_incoming_email_params(
      subject:        subject_line,
      recipient:      recipient,
      body_html:      body_html,
      body_plain:     body_plain,
      in_reply_to:    in_reply_to,
      auto_submitted: auto_submitted,
      envelope_from:  envelope_from,
    )
  end
  let(:incoming_email){ threadable.incoming_emails.create!(params).first }

  let(:subject_line)   { 'i am a subject line, see me subject' }
  let(:body_plain)     { 'i am a body, watch me bod.' }
  let(:body_html)      { '<body>i am a <strong>body</strong>, watch me bod.</body>' }
  let(:recipient)      { 'raceteam@localhost' }
  let(:to)             { 'UCSD Electric Racing <raceteam@localhost>' }
  let(:in_reply_to)    { nil }
  let(:auto_submitted) { nil }
  let(:envelope_from)  { "alice@ucsd.example.com" }

  before do
    incoming_email.find_organization!
    incoming_email.find_groups!
    incoming_email.find_conversation!
  end

  describe "#message_held_notice" do
    let(:mail){ described_class.new(threadable).generate(:message_held_notice, incoming_email) }

    it "sends a held notice" do
      expect(mail.subject).to eq "[message held] i am a subject line, see me subject"
      expect(mail.to     ).to eq [incoming_email.envelope_from]

      expect(mail.smtp_envelope_from).to eq "no-reply-auto@localhost"
    end

    context 'for an auto-response' do
      let(:auto_submitted) { 'auto-replied' }

      it 'does nothing' do
        expect(mail).to be_a ActionMailer::Base::NullMail
      end
    end

    context 'for a message with a null envelope sender' do
      let(:envelope_from) { '<>' }

      it 'does nothing' do
        expect(mail).to be_a ActionMailer::Base::NullMail
      end
    end
  end

  describe "#message_bounced_dsn" do
    let(:text_part)             { mail.parts[0] }
    let(:delivery_status_part)  { mail.parts[1] }
    let(:original_mail_part) { mail.parts[2] }

    let(:mail){ described_class.new(threadable).generate(:message_bounced_dsn, incoming_email) }

    context 'when the organization/group cannot be found' do
      let(:recipient)    { 'not-there@localhost' }
      let(:to)           { 'This is wrong <not-there@localhost>' }

      it "sends a delivery status notification" do
        expect(mail.subject).to eq "Delivery Status Notification (Failure)"

        expect(mail.header['In-Reply-To'].to_s).to eq params['Message-Id']
        expect(mail.header['References'].to_s).to  eq params['Message-Id']

        expect(mail.header['X-Mailgun-Track'].to_s).to       eq 'no'
        expect(mail.header['X-Mailgun-Native-Send'].to_s).to eq 'true'

        expect(mail.to).to eq [envelope_from]
        expect(mail.from).to eq ['no-reply-auto@localhost']
        expect(mail.smtp_envelope_from).to eq ""

        expect(mail.content_type).to include 'multipart/report'
        expect(mail.content_type).to include 'report-type=delivery-status'

        expect(text_part.content_type).to eq 'text/plain'
        expect(text_part.body).to include subject_line
        expect(text_part.body).to include 'The threadable organization/group you tried to reach does not exist.'

        expect(delivery_status_part.content_type).to eq 'message/delivery-status'

        expect(delivery_status_part.body.to_s).to include "Reporting-MTA: dns;mxa.127.0.0.1"
        expect(delivery_status_part.body.to_s).to include "Arrival-Date:"
        expect(delivery_status_part.body.to_s).to include "Final-Recipient: rfc822;not-there@localhost"
        expect(delivery_status_part.body.to_s).to include "Original-Recipient: rfc822;not-there@localhost"
        expect(delivery_status_part.body.to_s).to include "Action: failed"
        expect(delivery_status_part.body.to_s).to include "Status: 5.1.1"
        expect(delivery_status_part.body.to_s).to include "Diagnostic-Code: smtp; 550-5.1.1"

        expect(original_mail_part.content_type).to eq 'message/rfc822'

        JSON.parse(incoming_email.params['message-headers']).each do |header_and_value|
          (header, value) = header_and_value
          header_object = Mail::Header.new
          header_object.fields = ["#{header}: #{value}"]
          expect(original_mail_part.body.to_s).to include header_object.to_s.gsub(/\r/, '')
        end

        expect(original_mail_part.body.to_s).to include "i am a body"
      end
    end

    context 'with a blank message' do
      let(:subject_line) { '' }
      let(:body_plain)   { '' }
      let(:body_html)    { '' }

      it 'bounces the message with an error about how the message is blank' do
        expect(delivery_status_part.body.to_s).to include "Diagnostic-Code: smtp; 550-5.6.0"
        expect(delivery_status_part.body.to_s).to include "Status: 5.6.0"
        expect(text_part.body).to include 'Threadable cannot deliver a blank message with no subject.'
      end
    end

    context 'with a message that is to a conversation that is in the trash' do
      let(:conversation) { organization.conversations.find_by_slug!('omg-i-am-so-drunk') }
      let(:in_reply_to)  { conversation.messages.last.message_id_header }

      it 'bounces the message with an error about how the conversation is deleted' do
        expect(delivery_status_part.body.to_s).to include "Diagnostic-Code: smtp; 550-5.6.0"
        expect(delivery_status_part.body.to_s).to include "Status: 5.6.0"
        expect(text_part.body).to include 'You attempted to reply to a deleted conversation.'
      end
    end

    context 'for an auto-response' do
      let(:auto_submitted) { 'auto-replied' }

      it 'does nothing' do
        expect(mail).to be_a ActionMailer::Base::NullMail
      end
    end

    context 'for a message with a null envelope sender' do
      let(:envelope_from) { '<>' }

      it 'does nothing' do
        expect(mail).to be_a ActionMailer::Base::NullMail
      end
    end
  end

end
