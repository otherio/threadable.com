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

end
