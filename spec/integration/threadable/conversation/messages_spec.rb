require 'spec_helper'

describe Threadable::Conversation::Messages do
  let(:organization) { threadable.organizations.find_by_slug!('raceteam') }

  describe '#not_sent_to' do
    let(:conversation) { organization.conversations.find_by_slug!('parts-for-the-motor-controller') }
    let(:user) { organization.members.find_by_email_address('alice@ucsd.example.com') }

    it 'finds the messages that were not sent to the given user' do
      messages = conversation.messages.not_sent_to(user)
      expect(messages.length).to eq 1
      expect(messages.first).to be_a Threadable::Message
    end
  end

  describe '#create' do
    context 'when the conversation has been deleted' do
      let(:conversation) { organization.conversations.find_by_slug!('omg-i-am-so-drunk') }

      it 'raises an error' do
        expect{conversation.messages.create(body: 'hi. is this thing on?')}.to raise_error Threadable::AuthorizationError, 'This conversation has been deleted. Remove it from the trash before replying.'
      end
    end
  end
end
