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
    )
  end
  let(:incoming_email){ threadable.incoming_emails.create!(params).first }

  let(:subject_line)       { 'i am a subject line, see me subject' }

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


end
