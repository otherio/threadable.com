require 'spec_helper'

describe Threadable::IncomingEmail::Deliver do
  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }

  let :params do
    create_incoming_email_params(
      subject:       subject_line,
      recipient:     recipient,
      body_html:     body_html,
      body_plain:    body_plain,
      in_reply_to:   in_reply_to,
      to:            to,
    )
  end
  let(:incoming_email){ threadable.incoming_emails.create!(params).first }

  let(:in_reply_to)  { nil }
  let(:subject_line) { 'i am a subject line, see me subject' }
  let(:body_plain)   { 'i am a body, watch me bod.' }
  let(:body_html)    { '<body>i am a <strong>body</strong>, watch me bod.</body>' }
  let(:recipient)    { 'raceteam@localhost' }
  let(:to)           { 'UCSD Electric Racing <raceteam@localhost>' }


  delegate :call, to: described_class

  before do
    sign_in_as 'alice@ucsd.example.com'

    parent_message_record = conversation.messages.last.message_record
    parent_message_record.update_attribute :to_header, "UCSD Electric Racing <raceteam@localhost>"

    incoming_email.find_organization!
    incoming_email.find_parent_message!
    incoming_email.find_groups!
    incoming_email.find_message!
    incoming_email.find_creator!
    incoming_email.find_conversation!
  end

  describe "sync_groups_from_headers!" do
    let(:parent_message) { conversation.messages.last }
    let(:in_reply_to)    { parent_message.message_id_header }
    let(:to)             { 'fundraising@raceteam.localhost' }

    it 'adds groups found in the to and cc headers' do
      call incoming_email
      conversation.conversation_record.reload
      expect(conversation.groups.all.map(&:slug)).to match_array ['fundraising']
    end

    context 'when the primary group has been renamed' do
      let(:to) { 'fundraising@raceteam.localhost, raceteam@localhost' }

      before do
        organization.groups.primary.update(name: 'Main', email_address_tag: 'main')
      end

      it 'retains the primary group' do
        call incoming_email
        conversation.conversation_record.reload
        expect(conversation.groups.all.map(&:slug)).to match_array ['fundraising', 'main']
      end
    end
  end

end
