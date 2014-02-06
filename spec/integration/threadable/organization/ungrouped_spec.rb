require 'spec_helper'

describe Threadable::Organization::Ungrouped do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:ungrouped){ described_class.new(organization) }
  subject{ ungrouped }


  when_signed_in_as 'bethany@ucsd.example.com' do

    describe 'muted_conversations' do
      context 'when given 0' do
        it 'returns the muted_conversations for the current user' do
          expect(sligs_for ungrouped.muted_conversations(0)).to eq [
            "get-carbon-and-fiberglass",
            "get-release-agent",
            "get-epoxy",
            "layup-body-carbon",
            "welcome-to-our-threadable-organization"
          ]
        end
      end
    end

    describe 'not_muted_conversations' do
      context 'when given 0' do
        it 'returns the not_muted_conversations for the current user' do
          expect(sligs_for ungrouped.not_muted_conversations(0)).to eq [
            "who-wants-to-pick-up-breakfast",
            "who-wants-to-pick-up-dinner",
            "who-wants-to-pick-up-lunch",
            "make-wooden-form-for-carbon-layup",
            "trim-body-panels",
            "install-mirrors",
            "how-are-we-going-to-build-the-body"
          ]
        end
      end
    end

    describe 'done_tasks' do
      context 'when given 0' do
        it 'returns the done_tasks for the current user' do
          expect(sligs_for ungrouped.done_tasks(0)).to eq [
            "get-epoxy",
            "get-release-agent",
            "get-carbon-and-fiberglass",
            "layup-body-carbon"
          ]
        end
      end
    end

    describe 'not_done_tasks' do
      context 'when given 0' do
        it 'returns the not_done_tasks for the current user' do
          expect(sligs_for ungrouped.not_done_tasks(0)).to eq [
            "install-mirrors",
            "trim-body-panels",
            "make-wooden-form-for-carbon-layup"
          ]
        end
      end
    end

    describe 'done_doing_tasks' do
      context 'when given 0' do
        it 'returns the done_doing_tasks for the current user' do
          expect(sligs_for ungrouped.done_doing_tasks(0)).to eq []
        end
      end
    end

    describe 'not_done_doing_tasks' do
      context 'when given 0' do
        it 'returns the not_done_doing_tasks for the current user' do
          expect(sligs_for ungrouped.not_done_doing_tasks(0)).to eq []
        end
      end
    end


  end


  def sligs_for conversations
    conversations.map(&:slug)
  end

end
