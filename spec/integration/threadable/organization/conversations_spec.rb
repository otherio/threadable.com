require 'spec_helper'

describe Threadable::Organization::Conversations, :type => :request do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:conversations){ described_class.new(organization) }

  when_not_signed_in do
    describe '#muted' do
      it 'returns an empty array' do
        expect(conversations.muted.map(&:slug)).to eq []
      end
    end
    describe '#not_muted' do
      it 'returns an empty array' do
        expect(conversations.not_muted.map(&:slug)).to eq []
      end
    end
    describe '#muted_with_participants' do
      it 'returns an empty array' do
        expect(conversations.muted_with_participants.map(&:slug)).to eq []
      end
    end
    describe '#not_muted_with_participants' do
      it 'returns an empty array' do
        expect(conversations.not_muted_with_participants.map(&:slug)).to eq []
      end
    end

    describe '#find_by_slug' do
      it 'does not find the private conversation' do
        expect(organization.conversations.find_by_slug('recruiting')).to be_nil
      end

      it 'finds the partly-private conversation' do
        expect(organization.conversations.find_by_slug('budget-worknight')).to be_a Threadable::Conversation
      end
    end

  end

  when_signed_in_as 'bethany@ucsd.example.com' do
    let :muted_conversation_slugs do
      [
        "layup-body-carbon",
        "get-carbon-and-fiberglass",
        "get-release-agent",
        "get-epoxy",
        "parts-for-the-drive-train",
        "welcome-to-our-threadable-organization",
      ]
    end

    let :not_muted_conversation_slugs do
      [
        "who-wants-to-pick-up-breakfast",
        "who-wants-to-pick-up-dinner",
        "who-wants-to-pick-up-lunch",
        "get-some-4-gauge-wire",
        "get-a-new-soldering-iron",
        "make-wooden-form-for-carbon-layup",
        "trim-body-panels",
        "install-mirrors",
        "how-are-we-paying-for-the-motor-controller",
        "parts-for-the-motor-controller",
        "how-are-we-going-to-build-the-body",
        "drive-trains-are-expensive",
        "inventory-led-supplies",
        "budget-worknight",
      ]
    end

    describe '#muted' do
      it 'returns an empty array' do
        expect(conversations.muted.map(&:slug)).to match_array muted_conversation_slugs
      end
    end
    describe '#not_muted' do
      it 'returns an empty array' do
        expect(conversations.not_muted.map(&:slug)).to match_array not_muted_conversation_slugs
      end
    end
    describe '#muted_with_participants' do
      it 'returns an empty array' do
        expect(conversations.muted_with_participants.map(&:slug)).to match_array muted_conversation_slugs
      end
    end
    describe '#not_muted_with_participants' do
      it 'returns an empty array' do
        expect(conversations.not_muted_with_participants.map(&:slug)).to match_array not_muted_conversation_slugs
      end
    end

    describe '#find_by_slug' do
      it 'does not find the private conversation' do
        expect(organization.conversations.find_by_slug('recruiting')).to be_nil
      end

      it 'finds the partly-private conversation' do
        expect(organization.conversations.find_by_slug('budget-worknight')).to be_a Threadable::Conversation
      end
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do
    describe '#find_by_slug' do
      it 'finds the private conversation' do
        expect(organization.conversations.find_by_slug('recruiting')).to be_a Threadable::Conversation
      end

      it 'finds the partly-private conversation' do
        expect(organization.conversations.find_by_slug('budget-worknight')).to be_a Threadable::Conversation
      end

      context 'when not a member of the group' do
        let(:leaders) { organization.groups.find_by_slug('leaders') }

        before do
          leaders.members.remove(threadable.current_user)
        end

        it 'still finds the private conversation' do
          expect(organization.conversations.find_by_slug('recruiting')).to be_a Threadable::Conversation
        end
      end
    end
  end

end
