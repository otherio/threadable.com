require 'spec_helper'

describe Covered::Organization do

  let(:organization_record){ find_organization_by_slug('raceteam') }
  let(:organization){ described_class.new(covered, organization_record) }
  subject{ organization }


  describe 'destroy!' do
    it 'destroys the organization, organization memberships, conversations and messages' do
      organization_id = organization.id

      membership_ids   = organization_record.memberships.map(&:id)
      conversation_ids = organization_record.conversations.map(&:id)
      message_ids      = organization_record.messages.map(&:id)
      event_ids        = organization_record.events.map(&:id)

      organization.destroy!
      expect( ::Organization.where(id: organization_id)               ).to be_empty
      expect( ::OrganizationMembership.where(id: membership_ids) ).to be_empty
      expect( ::Conversation.where(id: conversation_ids)    ).to be_empty
      expect( ::Message.where(id: message_ids)              ).to be_empty
      expect( ::Event.where(id: event_ids)                  ).to be_empty
    end
  end

  describe 'scopes' do
    when_signed_in_as 'bethany@ucsd.example.com' do

      describe 'muted_conversations' do
        it "returns the conversations bethany has muted" do
          conversations = organization.muted_conversations
          conversations.each do |conversation|
            expect(conversation).to be_a Covered::Conversation
            expect(conversation).to be_muted_by current_user
          end

          expect( slugs_for conversations ).to match_array [
            "layup-body-carbon",
            "get-carbon-and-fiberglass",
            "get-release-agent",
            "get-epoxy",
            "parts-for-the-drive-train",
            "welcome-to-our-covered-organization"
          ]
        end
      end
      describe 'not_muted_conversations' do
        it "returns the conversations bethany has not muted" do
          conversations = organization.not_muted_conversations
          conversations.each do |conversation|
            expect(conversation).to be_a Covered::Conversation
            expect(conversation).to_not be_muted_by current_user
          end
          expect( slugs_for conversations ).to match_array [
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
          ]
        end
      end
      describe 'done_tasks' do
        it "returns all the done tasks" do
          tasks = organization.done_tasks
          tasks.each do |task|
            expect(task).to be_a Covered::Task
            expect(task).to be_done
          end
          expect( slugs_for tasks ).to eq [
            "layup-body-carbon",
            "get-epoxy",
            "get-release-agent",
            "get-carbon-and-fiberglass",
          ]
        end
      end
      describe 'not_done_tasks' do
        it "returns all the not done tasks" do
          tasks = organization.not_done_tasks
          tasks.each do |task|
            expect(task).to be_a Covered::Task
            expect(task).to_not be_done
          end
          expect( slugs_for tasks ).to eq [
            "install-mirrors",
            "trim-body-panels",
            "make-wooden-form-for-carbon-layup",
            "get-a-new-soldering-iron",
            "get-some-4-gauge-wire",
          ]
        end
      end
      describe 'done_doing_tasks' do
        it "returns all the done tasks bethany is doing" do
          tasks = organization.done_doing_tasks
          tasks.each do |task|
            expect(task).to be_a Covered::Task
            expect(task).to be_done
            expect(task).to be_being_done_by current_user
          end
          expect( slugs_for tasks ).to eq [

          ]
        end
      end
      describe 'not_done_doing_tasks' do
        it "returns all the not done tasks bethany is doing" do
          tasks = organization.not_done_doing_tasks
          tasks.each do |task|
            expect(task).to be_a Covered::Task
            expect(task).to_not be_done
            expect(task).to be_being_done_by current_user
          end
          expect( slugs_for tasks ).to eq [
            "get-a-new-soldering-iron",
          ]
        end
      end

    end

    def slugs_for collection
      collection.map(&:slug)
    end

  end

end
