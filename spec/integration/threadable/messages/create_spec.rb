require 'spec_helper'

describe Threadable::Messages::Create do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:conversation) { organization.conversations.find_by_slug('layup-body-carbon') }
  let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com') }

  delegate :call, to: described_class

  let(:message_options) do
    {
      conversation: conversation,
      from: 'alice@ucsd.example.com',
      body: 'This is the text of the message',
      creator: alice
    }
  end

  describe 'algolia search' do
    it 'creates the message and then indexes it separately' do
      expect_any_instance_of(Message).to receive(:index!)

      message = call(conversation.messages, message_options)

      expect(message.creator).to eq alice
      expect(message.body_plain).to eq 'This is the text of the message'
    end

    it 'succeeds when algolia refuses to index because of a quota error' do

      expect_any_instance_of(Message).to receive(:index!).and_raise(
        Algolia::AlgoliaProtocolError.new(400, 'Cannot PUT to https://FOO-3.algolia.io/1/indexes/messages/12345: {"message":"Record is too big size=234567 bytes. Contact us if you need an extended quota" }')
      )

      message = call(conversation.messages, message_options)

      expect(message.creator).to eq alice
      expect(message.body_plain).to eq 'This is the text of the message'
    end

    it 'fails for other sorts of algolia error' do
      expect_any_instance_of(Message).to receive(:index!).and_raise(
        Algolia::AlgoliaProtocolError.new(401, 'Go away')
      )

      expect { call(conversation.messages, message_options) }.to raise_error
    end
  end
end
