# Encoding: UTF-8
require "spec_helper"

describe IncomingEmailMailer do

  signed_in_as 'bethany@ucsd.example.com'

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
  let(:group) { organization.groups.find_by_email_address_tag('electronics') }

  let :params do
    create_incoming_email_params(
      subject:       subject_line,
      recipient:     recipient,
    )
  end
  let(:incoming_email){ threadable.incoming_emails.create!(params).first }

  let(:subject_line) { 'i am a subject line, see me subject' }
  let(:recipient)    { 'raceteam@localhost' }
  let(:to)           { 'UCSD Electric Racing <raceteam@localhost>' }

  before do
    incoming_email.find_organization!
    incoming_email.find_groups!
  end

  describe "#message_held_notice" do
    let(:mail){ described_class.new(threadable).generate(:message_held_notice, incoming_email) }

    it "sends a held notice" do
      expect(mail.subject).to eq "[message held] i am a subject line, see me subject"
      expect(mail.to     ).to eq [incoming_email.envelope_from]

      expect(mail.smtp_envelope_from).to eq "no-reply-auto@localhost"
    end
  end

  describe "#message_bounced_notice" do
    let(:recipient)    { 'not-there@localhost' }
    let(:to)           { 'This is wrong <not-there@localhost>' }

    let(:mail){ described_class.new(threadable).generate(:message_bounced_notice, incoming_email) }

    it "sends a delivery status notification" do
      expect(mail.subject).to eq "Delivery Status Notification (Failure)"

      expect(mail.header['In-Reply-To'].to_s).to eq params['Message-Id']
      expect(mail.header['References'].to_s).to  eq params['Message-Id']

      expect(mail.to).to eq [params['X-Envelope-From']]
      expect(mail.from).to eq ['no-reply-auto@localhost']
      expect(mail.smtp_envelope_from).to eq "no-reply-auto@localhost"

      expect(mail.content_type).to include 'multipart/report'
      expect(mail.content_type).to include 'report-type=delivery-status'

      text_part = mail.parts[0]
      delivery_status_part = mail.parts[1]
      original_headers_part = mail.parts[2]

      expect(text_part.content_type).to eq 'text/plain'
      expect(text_part.body).to include subject_line

      expect(delivery_status_part.content_type).to eq 'message/delivery-status'

      expect(delivery_status_part.body.to_s).to include "Final-Recipient: rfc822;not-there@localhost"
      expect(delivery_status_part.body.to_s).to include "Original-Recipient: rfc822;not-there@localhost"
      expect(delivery_status_part.body.to_s).to include "Action: failed"
      expect(delivery_status_part.body.to_s).to include "Status: 5.1.1"
      expect(delivery_status_part.body.to_s).to include "Remote-MTA: dns;mxa.127.0.0.1"
      expect(delivery_status_part.body.to_s).to include "Diagnostic-Code: smtp; 550-5.1.1"

      expect(original_headers_part.content_type).to eq 'message/rfc822'

      JSON.parse(incoming_email.params['message-headers']).each do |header_and_value|
        (header, value) = header_and_value
        header_object = Mail::Header.new
        header_object.fields = ["#{header}: #{value}"]
        expect(original_headers_part.body.to_s).to include header_object.to_s.gsub(/\r/, '')
      end
    end
  end

end
