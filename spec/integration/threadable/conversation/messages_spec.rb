require 'spec_helper'

describe Threadable::Conversation::Messages do
  let(:organization) { threadable.organizations.find_by_slug!('raceteam') }

  describe '#create' do
    context 'when the conversation has been deleted' do
      let(:conversation) { organization.conversations.find_by_slug!('omg-i-am-so-drunk') }

      it 'raises an error' do
        expect{conversation.messages.create(body: 'hi. is this thing on?')}.to raise_error Threadable::AuthorizationError, 'This conversation has been deleted. Remove it from the trash before replying.'
      end
    end
  end
end
