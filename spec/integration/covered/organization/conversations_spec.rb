require 'spec_helper'

describe Covered::Organization::Conversations do

  let(:organization){ covered.organizations.find_by_slug! 'raceteam' }
  let(:conversations){ described_class.new(organization) }

  describe 'not_muted_with_participants' do

    when_not_signed_in do
      it 'returns an empty array' do
        expect(conversations.not_muted_with_participants).to eq []
      end
    end

    when_signed_in_as 'tom@ucsd.example.com' do
      it 'returns all the conversations' do
        expect(conversations.not_muted_with_participants).to eq conversations.all
      end
    end

    when_signed_in_as 'bethany@ucsd.example.com' do
      let(:muted_conversation){ conversations.find_by_slug!('welcome-to-our-covered-organization') }
      it 'returns all but the one muted conversation' do
        expect(conversations.not_muted_with_participants).to eq(conversations.all - [muted_conversation])
      end
    end

  end

  describe 'muted_with_participants' do

    when_not_signed_in do
      it 'returns an empty array' do
        expect(conversations.muted_with_participants).to eq []
      end
    end

    when_signed_in_as 'tom@ucsd.example.com' do
      it 'returns an empty array' do
        expect(conversations.muted_with_participants).to eq []
      end
    end

    when_signed_in_as 'bethany@ucsd.example.com' do
      let(:muted_conversation){ conversations.find_by_slug!('welcome-to-our-covered-organization') }
      it 'returns all but the one muted conversation' do
        expect(conversations.muted_with_participants).to eq [muted_conversation]
      end
    end

  end

end
