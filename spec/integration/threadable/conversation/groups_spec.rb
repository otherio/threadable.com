require 'spec_helper'

describe Threadable::Conversation::Groups do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }
  let(:all_groups) { organization.groups.all }
  let(:groups){ conversation.groups }
  let(:primary_group){ organization.groups.primary }
  let(:electronics) { organization.groups.find_by_email_address_tag('electronics') }


  subject{ groups }

  its(:all){ should eq [primary_group] }

  describe '#add' do

    it 'should add the given groups to the conversation' do
      group1, group2 = all_groups.last(2)

      expect(conversation.groups.all).to eq [primary_group]
      expect(conversation.groups.count).to eq 1
      expect(conversation.group_ids).to eq [primary_group.id]

      conversation.groups.add(group1)

      expect(conversation.groups.all).to match_array [primary_group, group1]
      expect(conversation.groups.count).to eq 2
      expect(conversation.group_ids).to match_array [primary_group.id, group1.id]

      conversation.groups.add(group2)

      expect(conversation.groups.all).to match_array [primary_group, group1, group2]
      expect(conversation.groups.count).to eq 3
      expect(conversation.group_ids).to match_array [primary_group.id, group1.id, group2.id]

      events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
      expect(events).to eq [
        [:conversation_added_group, group1.id],
        [:conversation_added_group, group2.id],
      ]
    end

    context 'when a given group was already removed from the conversation' do
      let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }

      it 'should add the given groups to the conversation' do
        expect(conversation.groups.all).to eq [electronics]

        conversation.groups.remove(electronics)

        expect(conversation.groups.all).to eq [primary_group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [primary_group.id]

        conversation.groups.add(electronics)

        expect(conversation.groups.all).to match_array [electronics, primary_group]
        expect(conversation.groups.count).to eq 2
        expect(conversation.group_ids).to match_array [electronics.id, primary_group.id]

        events = conversation.events.all.last(3).map{|e| [e.event_type, e.group_id]}
        expect(events).to eq [
          [:conversation_removed_group, electronics.id],
          [:conversation_added_group,   primary_group.id],
          [:conversation_added_group,   electronics.id],
        ]
      end

    end

  end

  describe '#add_unless_removed' do

    it 'should add the given groups to the conversation' do
      added_groups = all_groups.last(2)
      expected_groups = added_groups + [primary_group]
      expect(conversation.groups.all).to eq [primary_group]
      expect(conversation.groups.count).to eq 1
      expect(conversation.group_ids).to eq [primary_group.id]

      conversation.groups.add_unless_removed(added_groups)

      expect(conversation.groups.all).to match_array expected_groups
      expect(conversation.groups.count).to eq 3
      expect(conversation.group_ids).to match_array expected_groups.map(&:id)

      events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
      expect(events).to eq [
        [:conversation_added_group, added_groups.first.id],
        [:conversation_added_group, added_groups.last.id],
      ]
    end

    context 'when a given group was already removed from the conversation' do
      let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }

      it 'should not add that group to the conversation' do
        expect(conversation.groups.all).to eq [electronics]

        conversation.groups.remove(electronics)

        starting_events_count = conversation.events.count

        expect(conversation.groups.all).to eq [primary_group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [primary_group.id]

        conversation.groups.add_unless_removed(electronics)

        expect(conversation.groups.all).to eq [primary_group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [primary_group.id]

        expect(conversation.events.count).to eq starting_events_count
      end

    end

  end

  describe '#remove' do
    let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }

    context 'with more than one group' do
      let(:fundraising) { organization.groups.find_by_email_address_tag('fundraising') }

      before do
        conversation.groups.add fundraising
      end

      it 'should remove the given groups from the conversation' do
        expect(conversation.groups.all).to match_array [electronics, fundraising]

        conversation.groups.remove(electronics)
        expect(conversation.groups.all).to eq [fundraising]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [fundraising.id]

        events = conversation.events.all.last(1).map{|e| [e.event_type, e.group_id]}
        expect(events).to eq [[:conversation_removed_group, electronics.id]]
      end
    end

    context 'with one group' do
      it 'removes the group and puts the conversation in the primary group' do
        expect(conversation.groups.all).to eq [electronics]

        conversation.groups.remove(electronics)
        expect(conversation.groups.all).to eq [primary_group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [primary_group.id]

        events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
        expect(events).to eq [
          [:conversation_removed_group, electronics.id],
          [:conversation_added_group,   primary_group.id],
        ]
      end
    end

    context 'when there is one group and it is primary' do
      let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }

      it 'does not change the groups, and creates no events' do
        expect(conversation.groups.all).to eq [primary_group]

        conversation.groups.remove(primary_group)
        expect(conversation.groups.all).to eq [primary_group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [primary_group.id]

        events = conversation.events.all.last(1).map{|e| e.event_type}
        expect(events).to_not eq [:conversation_removed_group]
      end
    end
  end

end
