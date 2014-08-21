require 'spec_helper'

describe Threadable::Messages::Create, :type => :request do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:conversation) { organization.conversations.find_by_slug('layup-body-carbon') }
  let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com') }

  delegate :call, to: described_class

  let(:message_options) do
    {
      conversation: conversation,
      from: 'alice@ucsd.example.com',
      body: 'This is the text of the message',
      creator: alice,
      to_header: to_header
    }
  end

  context 'with no to/cc header' do
    let(:to_header) { nil }

    it 'creates the message, adding a to header' do
      message = call(conversation.messages, message_options)

      expect(message.creator).to eq alice
      expect(message.body_plain).to eq 'This is the text of the message'
      expect(message.to_header).to eq 'UCSD Electric Racing Tasks <raceteam+task@raceteam.localhost>'
    end

    context 'with multiple groups' do
      let(:conversation) { organization.conversations.find_by_slug('get-some-4-gauge-wire') }

      it 'puts all the addresses in the to header' do
        message = call(conversation.messages, message_options)

        expect(message.to_header.split(',')).to match_array [
          '"UCSD Electric Racing: Electronics Tasks" <electronics+task@raceteam.localhost>',
          '"UCSD Electric Racing: Fundraising Tasks" <fundraising+task@raceteam.localhost>'
        ]
      end
    end

    context 'when the member is not a conversation participant' do
      let(:conversation) { organization.conversations.find_by_slug('get-a-new-soldering-iron') }

      it 'adds the member as a follower' do
        expect(conversation.followed_by?(alice)).to be_falsey
        message = call(conversation.messages, message_options)
        expect(conversation.followed_by?(alice)).to be_truthy
      end
    end
  end

  context 'with a to header' do
    let(:to_header) { 'Foo Bathtub <hot-water@whoo.yeah>' }

    it 'leaves the to header alone' do
      message = call(conversation.messages, message_options)
      expect(message.to_header).to eq 'Foo Bathtub <hot-water@whoo.yeah>'
    end
  end

end
