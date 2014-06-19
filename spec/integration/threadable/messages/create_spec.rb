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

  it 'creates the message' do
    message = call(conversation.messages, message_options)

    expect(message.creator).to eq alice
    expect(message.body_plain).to eq 'This is the text of the message'
  end
end
