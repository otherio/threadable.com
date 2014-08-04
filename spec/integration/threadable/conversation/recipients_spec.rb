require 'spec_helper'

describe Threadable::Conversation::Recipients do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.latest }
  let(:recipients){ conversation.recipients }

  subject{ recipients }

  describe '#all' do

    context 'when the conversation is in a group' do
      let(:conversation) { threadable.conversations.find_by_slug!('parts-for-the-motor-controller') }

      it "returns all the members of that conversation's groups who get email minus the members who have muted this conversation" do
        expected_recipients = conversation.groups.all.map{|g| g.members.all}.flatten(1).uniq.map(&:slug)
        expect( recipients.all.map(&:slug) ).to match_array expected_recipients
      end
    end

    context 'when the conversation is in the primary group' do
      let(:conversation) { threadable.conversations.find_by_slug!('welcome-to-our-threadable-organization') }

      it 'returns all the members of the primary group minus the members who have muted this conversation' do
        expected_recipients = ["alice-neilson", "bob-cauchois", "lilith-sternin", "nadya-leviticon", "tom-canver", "yan-hzu"]
        expect( recipients.all.map(&:slug) ).to match_array expected_recipients
      end

    end

    context 'when the conversation has a follower' do
      let(:conversation) { threadable.conversations.find_by_slug!('parts-for-the-motor-controller') }
      let(:user) { organization.members.find_by_email_address('alice@ucsd.example.com') }

      before do
        conversation.follow_for user
      end

      it 'includes the follower' do
        expected_recipients = ["alice-neilson", "tom-canver", "bethany-pattern"]
        expect( recipients.all.map(&:slug) ).to match_array expected_recipients
      end

      context 'when the follower has unsubscribed' do
        let(:user) { organization.members.find_by_email_address('jonathan@ucsd.example.com') }

        it 'does not include the follower' do
          expected_recipients = ["tom-canver", "bethany-pattern"]
          expect( recipients.all.map(&:slug) ).to match_array expected_recipients
        end
      end

    end

  end

end
