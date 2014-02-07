require 'spec_helper'

describe Threadable::Organization::Group do

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:group){ organization.groups.find_by_slug! 'electronics' }
  subject{ group }

  when_signed_in_as 'bethany@ucsd.example.com' do

    describe '#muted_conversations' do
      context 'when given 0' do
        it 'returns the muted_conversations for the current user' do
          expect(slugs_for subject.muted_conversations(0)).to eq [
            "parts-for-the-drive-train"
          ]
        end
      end
    end

    describe '#not_muted_conversations' do
      context 'when given 0' do
        it 'returns the not_muted_conversations for the current user' do
          expect(slugs_for subject.not_muted_conversations(0)).to eq [
            "get-a-new-soldering-iron",
            "get-some-4-gauge-wire",
            "drive-trains-are-expensive",
            "parts-for-the-motor-controller",
          ]
        end
      end
    end

    describe '#done_tasks' do
      context 'when given 0' do
        it 'returns the done_tasks for the current user' do
          expect(slugs_for subject.done_tasks(0)).to eq [

          ]
        end
      end
    end

    describe '#not_done_tasks' do
      context 'when given 0' do
        it 'returns the not_done_tasks for the current user' do
          expect(slugs_for subject.not_done_tasks(0)).to eq [
            "get-a-new-soldering-iron",
            "get-some-4-gauge-wire",
          ]
        end
      end
    end

    describe '#done_doing_tasks' do
      context 'when given 0' do
        it 'returns the done_doing_tasks for the current user' do
          expect(slugs_for subject.done_doing_tasks(0)).to eq [

          ]
        end
      end
    end

    describe '#not_done_doing_tasks' do
      context 'when given 0' do
        it 'returns the not_done_doing_tasks for the current user' do
          expect(slugs_for subject.not_done_doing_tasks(0)).to eq [
            "get-a-new-soldering-iron",
          ]
        end
      end
    end

  end



  def slugs_for conversations
    conversations.map(&:slug)
  end


end
