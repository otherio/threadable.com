require 'spec_helper'

describe Threadable::Conversation::Recipients do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.latest }
  let(:recipients){ conversation.recipients }

  subject{ recipients }

  describe '#all' do

    context 'when the conversation is in a group' do
      let(:conversation) { threadable.conversations.find_by_slug!('parts-for-the-motor-controller') }

      it "returns all the members of that conversation's groups who get email" do
        expected_recipients = conversation.groups.all.map{|g| g.members.all}.flatten(1).uniq
        expect( recipients.all.map(&:user_id) ).to match_array expected_recipients.map(&:user_id)
      end
    end

    context 'when the conversation is not in a group' do
      let(:conversation) { threadable.conversations.find_by_slug!('welcome-to-our-threadable-organization') }

      it 'returns all the members of the organization who get email minus the members who have muted this conversation' do
        expected_recipients = conversation.organization.members.who_get_email.reject do |user|
          conversation.muted_by? user
        end
        expect( recipients.all.map(&:user_id) ).to match_array expected_recipients.map(&:user_id)
      end
    end

    context 'when the conversation is not saved' do
      let(:conversation) { organization.conversations.new }

      it 'returns all the members of the organization who get email' do
        expect( recipients.all.map(&:user_id) ).to match_array conversation.organization.members.who_get_email.map(&:user_id)
      end
    end

  end

end
