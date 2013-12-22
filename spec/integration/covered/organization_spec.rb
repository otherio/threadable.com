require 'spec_helper'

describe Covered::Organization do

  let(:project_record){ find_project_by_slug('raceteam') }
  let(:project){ described_class.new(covered, project_record) }
  subject{ project }


  describe 'destroy!' do
    it 'destroys the project, project memberships, conversations and messages' do
      project_id = project.id

      membership_ids   = project_record.memberships.map(&:id)
      conversation_ids = project_record.conversations.map(&:id)
      message_ids      = project_record.messages.map(&:id)
      event_ids        = project_record.events.map(&:id)

      project.destroy!
      expect( ::Organization.where(id: project_id)               ).to be_empty
      expect( ::OrganizationMembership.where(id: membership_ids) ).to be_empty
      expect( ::Conversation.where(id: conversation_ids)    ).to be_empty
      expect( ::Message.where(id: message_ids)              ).to be_empty
      expect( ::Event.where(id: event_ids)                  ).to be_empty
    end
  end

end
