require 'spec_helper'

describe Threadable::IncomingEmail::Deliver, :type => :request do
  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
  let(:fundraising) { organization.groups.find_by_slug! 'fundraising' }

  let :params do
    create_incoming_email_params(
      subject:       subject_line,
      recipient:     recipient,
      body_html:     body_html,
      body_plain:    body_plain,
      in_reply_to:   in_reply_to,
      to:            to,
      attachments:   attachments,
      message_id:    message_id,
    )
  end
  let(:incoming_email){ threadable.incoming_emails.create!(params).first }

  let(:in_reply_to)  { nil }
  let(:subject_line) { 'i am a subject line, see me subject' }
  let(:body_plain)   { 'i am a body, watch me bod.' }
  let(:body_html)    { '<body>i am a <strong>body</strong>, watch me bod.</body>' }
  let(:recipient)    { 'raceteam@localhost' }
  let(:to)           { 'UCSD Electric Racing <raceteam@localhost>' }
  let(:attachments)  { [] }
  let(:message_id)   { nil }

  delegate :call, to: described_class

  describe 'save_off_attachments!' do
    let :attachments do
      [
        RSpec::Support::Attachments.uploaded_file("some.gif", 'image/gif',  true),
      ]
    end

    let(:body_html) { '<img src="cid:somegifcontentid">' }

    before do
      sign_in_as 'alice@ucsd.example.com'

      incoming_email.find_organization!
      incoming_email.find_parent_message!
      incoming_email.find_groups!
      incoming_email.find_message!
      incoming_email.find_creator!
      incoming_email.find_conversation!
    end

    it 'turns on the inline flag for images that are inline' do
      call incoming_email
      conversation.conversation_record.reload
      expect(incoming_email.attachments.all.first.inline?).to be_truthy
    end

    describe 'when receiving the message for the second time' do
      let(:message_id) { conversation.messages.latest.message_id_header }

      it 'does not save attachments' do
        call incoming_email
        conversation.conversation_record.reload
        expect(incoming_email.attachments.all.length).to eq 0
      end
    end

  end

  describe "sync_groups_from_headers!" do
    let(:parent_message) { conversation.messages.last }
    let(:in_reply_to)    { parent_message.message_id_header }
    let(:to)             { 'fundraising@raceteam.localhost' }

    context 'with email headers on the parent message' do
      before do
        sign_in_as 'alice@ucsd.example.com'

        incoming_email.find_organization!
        incoming_email.find_parent_message!
        incoming_email.find_groups!
        incoming_email.find_message!
        incoming_email.find_creator!
        incoming_email.find_conversation!
      end

      it 'adds groups found in the to and cc headers' do
        call incoming_email
        conversation.conversation_record.reload
        expect(conversation.groups.all.map(&:slug)).to match_array ['fundraising']
        expect(conversation.group_ids).to match_array [fundraising.id]
        expect(conversation.groups.count).to eq 1
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

    context 'when there are no mail headers on the parent message' do
      before do
        sign_in_as 'alice@ucsd.example.com'

        parent_message_record = conversation.messages.last.message_record
        parent_message_record.update_attribute :to_header, ""

        incoming_email.find_organization!
        incoming_email.find_parent_message!
        incoming_email.find_groups!
        incoming_email.find_message!
        incoming_email.find_creator!
        incoming_email.find_conversation!
      end

      it 'does nothing' do
        call incoming_email
        conversation.conversation_record.reload
        expect(conversation.groups.all.map(&:slug)).to match_array ['raceteam']
      end
    end
  end

end
