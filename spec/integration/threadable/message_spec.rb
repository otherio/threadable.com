require 'spec_helper'

describe Threadable::Message do

  let(:conversation) { threadable.conversations.find_by_slug('inventory-led-supplies')}
  let(:organization) { conversation.organization }
  let(:message){ conversation.messages.latest }
  let(:recipient){ organization.members.find_by_email_address('cal.naughton@ucsd.example.com') }
  subject{ message }

  it "knows if it has been sent to a given recipient" do
    expect( message.sent_to?(recipient) ).to be_false
    message.sent_to!(recipient)
    expect( message.sent_to?(recipient) ).to be_true
  end

  describe '#avatar_url' do
    it 'knows its avatar url' do
      expect(message.avatar_url).to eq '/fixture_images/alice.jpg'
    end
  end

  describe '#sender_name' do
    it "gets the name of the user" do
      expect(message.sender_name).to eq 'Alice Neilson'
    end

    context 'with no message creator' do
      let(:message) { Threadable::Message.new(threadable, Message.where(user_id: nil).first)}

      it 'uses the name and email of the sender' do
        expect(message.sender_name).to eq '"Andy Lee Issacson" <andy@example.com>'
      end
    end
  end

  describe '#not_sent_to!' do
    before do
      message.sent_to!(recipient)
    end

    it 'changes the sent_to param' do
      message.not_sent_to!(recipient)
      expect(message.sent_to?(recipient)).to be_false
    end
  end

  describe '#send_email_for!' do
    it 'sends email for a specific user' do
      message.send_email_for!(recipient)
      expect(message.sent_to?(recipient)).to be_true
      drain_background_jobs!
      expect(sent_emails.length).to eq 1
    end

    it 'does nothing when the user has mail delivery turned off' do
      recipient.organization_membership_record.update_attribute(:gets_email, false)

      message.send_email_for!(recipient)
      expect(message.sent_to?(recipient)).to be_false
      drain_background_jobs!
      expect(sent_emails.length).to eq 0
    end
  end

end
