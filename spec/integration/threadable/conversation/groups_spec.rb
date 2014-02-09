require 'spec_helper'

describe Threadable::Conversation::Groups do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }
  let(:all_groups) { organization.groups.all.map {|g| Threadable::Group.new(threadable, g.group_record)} }
  let(:groups){ conversation.groups }

  subject{ groups }

  its(:all){ should be_empty }

  describe '#add' do

    it 'should add the given groups to the conversation' do
      new_groups = all_groups.first(2)
      expect(conversation.groups.all).to eq []
      conversation.groups.add(new_groups)
      expect(conversation.groups.all).to match_array new_groups
      expect(conversation.group_ids).to match_array new_groups.map(&:id)
      expect(conversation.events.all.length).to eq 6
    end

    context 'when a given group was already removed from the conversation' do
      let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }
      let(:group) { conversation.groups.all.first }

      it 'should add the given groups to the conversation' do
        expect(conversation.groups.all).to eq [group]

        conversation.groups.remove(group)
        expect(conversation.groups.all).to eq []

        conversation.groups.add(group)

        expect(conversation.groups.all).to eq [group]
        expect(conversation.group_ids).to eq [group.id]
        expect(conversation.events.all.map(&:event_type)).to eq [
          :conversation_created,
          :conversation_removed_group,
          :conversation_added_group,
        ]
      end

    end

  end

  describe '#add_unless_removed' do

    it 'should add the given groups to the conversation' do
      groups = all_groups.first(2)
      expect(conversation.groups.all).to eq []
      conversation.groups.add_unless_removed(groups)
      expect(conversation.groups.all).to match_array groups
      expect(conversation.group_ids).to match_array groups.map(&:id)
      expect(conversation.events.all.length).to eq 6
    end

    context 'when a given group was already removed from the conversation' do
      let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }
      let(:group) { conversation.groups.all.first }

      it 'should not add that group to the conversation' do
        expect(conversation.groups.all).to eq [group]

        conversation.groups.remove(group)
        expect(conversation.groups.all).to eq []

        conversation.groups.add_unless_removed(group)

        expect(conversation.groups.all).to eq []
        expect(conversation.group_ids).to eq []
        expect(conversation.events.all.map(&:event_type)).to eq [
          :conversation_created,
          :conversation_removed_group
        ]
      end

    end

  end

  describe '#remove' do
    let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }
    let(:group) { conversation.groups.all.first }

    it 'should remove the given groups from the conversation' do
      expect(conversation.groups.all).to eq [group]

      conversation.groups.remove(group)
      expect(conversation.groups.all).to eq []
      expect(conversation.group_ids).to eq []

      expect(conversation.events.all.map(&:event_type)).to eq [
        :conversation_created,
        :conversation_removed_group
      ]
    end

  end

end
