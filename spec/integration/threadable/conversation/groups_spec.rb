require 'spec_helper'

describe Threadable::Conversation::Groups do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }
  let(:all_groups) { organization.groups.all }
  let(:groups){ conversation.groups }

  subject{ groups }

  its(:all){ should be_empty }

  describe '#add' do

    it 'should add the given groups to the conversation' do
      group1, group2 = all_groups.first(2)

      expect(conversation.groups.all).to eq []
      expect(conversation.groups.count).to eq 0
      expect(conversation.group_ids).to eq []

      conversation.groups.add(group1)

      expect(conversation.groups.all).to match_array [group1]
      expect(conversation.groups.count).to eq 1
      expect(conversation.group_ids).to match_array [group1.id]

      conversation.groups.add(group2)

      expect(conversation.groups.all).to match_array [group1, group2]
      expect(conversation.groups.count).to eq 2
      expect(conversation.group_ids).to match_array [group1.id, group2.id]

      events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
      expect(events).to eq [
        [:conversation_added_group, group1.id],
        [:conversation_added_group, group2.id],
      ]
    end

    context 'when a given group was already removed from the conversation' do
      let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }
      let(:group) { conversation.groups.all.first }

      it 'should add the given groups to the conversation' do
        expect(conversation.groups.all).to eq [group]

        conversation.groups.remove(group)

        expect(conversation.groups.all).to eq []
        expect(conversation.groups.count).to eq 0
        expect(conversation.group_ids).to eq []

        conversation.groups.add(group)

        expect(conversation.groups.all).to eq [group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [group.id]

        events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
        expect(events).to eq [
          [:conversation_removed_group, group.id],
          [:conversation_added_group,   group.id],
        ]
      end

    end

  end

  describe '#add_unless_removed' do

    it 'should add the given groups to the conversation' do
      groups = all_groups.first(2)
      expect(conversation.groups.all).to eq []
      expect(conversation.groups.count).to eq 0
      expect(conversation.group_ids).to eq []

      conversation.groups.add_unless_removed(groups)

      expect(conversation.groups.all).to match_array groups
      expect(conversation.groups.count).to eq 2
      expect(conversation.group_ids).to match_array groups.map(&:id)

      events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
      expect(events).to eq [
        [:conversation_added_group, groups.first.id],
        [:conversation_added_group, groups.last.id],
      ]
    end

    context 'when a given group was already removed from the conversation' do
      let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }
      let(:group) { conversation.groups.all.first }

      it 'should not add that group to the conversation' do
        expect(conversation.groups.all).to eq [group]

        conversation.groups.remove(group)

        starting_events_count = conversation.events.count

        expect(conversation.groups.all).to eq []
        expect(conversation.groups.count).to eq 0
        expect(conversation.group_ids).to eq []

        conversation.groups.add_unless_removed(group)

        expect(conversation.groups.all).to eq []
        expect(conversation.groups.count).to eq 0
        expect(conversation.group_ids).to eq []

        expect(conversation.events.count).to eq starting_events_count
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
      expect(conversation.groups.count).to eq 0
      expect(conversation.group_ids).to eq []

      events = conversation.events.all.last(1).map{|e| [e.event_type, e.group_id]}
      expect(events).to eq [[:conversation_removed_group, group.id]]
    end

  end

end
