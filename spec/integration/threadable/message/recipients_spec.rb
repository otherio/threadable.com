require 'spec_helper'

describe Threadable::Message::Recipients, :type => :request do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.find_by_slug!('layup-body-carbon') }
  let(:recipients){ message.recipients }

  subject{ recipients }

  describe '#all' do
    let(:group) { conversation.groups.all.first }
    let(:first_message_member) { group.members.all.first }

    before do
      first_message_member.gets_first_message!
    end

    context 'when it is the first message in the conversation' do
      let(:message) { conversation.messages.first }

      it "includes the member with the first-message subscription" do
        expected_recipients = conversation.recipients.all.map(&:slug)
        expected_recipients << first_message_member.slug
        expect( recipients.all.map(&:slug) ).to include first_message_member.slug
        expect( recipients.all.map(&:slug) ).to match_array expected_recipients
      end
    end

    context 'for subsequent messages' do
      let(:message) { conversation.messages.last }

      it "excludes the member with the first-message subscription" do
        expected_recipients = conversation.recipients.all.map(&:slug)
        expect( recipients.all.map(&:slug) ).to match_array expected_recipients
        expect( recipients.all.map(&:slug) ).to_not include first_message_member.slug
      end
    end
  end

end
