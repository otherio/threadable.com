require 'spec_helper'

describe Threadable::Events::ConversationRemovedGroup, :type => :request do

  let(:events){ Threadable::Events.new(threadable) }

  describe '#create' do
    let(:raceteam){ threadable.organizations.find_by_slug('raceteam') }
    let(:conversation){ raceteam.conversations.find_by_slug('layup-body-carbon') }
    let(:group){ raceteam.groups.find_by_email_address_tag('electronics') }

    context "when given virtual attributes" do
      it 'serializes them in the content hash' do
        event = events.create(
          :conversation_removed_group,
          organization_id: raceteam.id,
          conversation_id: conversation.id,
          group_id: group.id
        )
        expect(event).to be_persisted
        expect(event).to be_a Threadable::Events::ConversationRemovedGroup
        expect(event.organization_id).to eq raceteam.id
        expect(event.conversation_id).to eq conversation.id
        expect(event.group_id).to eq group.id
      end
    end

  end

end
