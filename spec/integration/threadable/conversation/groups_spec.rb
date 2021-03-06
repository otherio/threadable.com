require 'spec_helper'

describe Threadable::Conversation::Groups, :type => :request do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }
  let(:groups){ conversation.groups }
  let(:primary_group){ organization.groups.primary }
  let(:electronics) { organization.groups.find_by_email_address_tag('electronics') }
  let(:fundraising) { organization.groups.find_by_email_address_tag('fundraising') }
  let(:graphic_design) { organization.groups.find_by_email_address_tag('graphic-design') }

  subject{ groups }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  describe '#all' do
    subject { super().all }
    it { is_expected.to eq [primary_group] }
  end

  describe '#add' do

    it 'should add the given groups to the conversation' do
      expect(conversation.groups.all).to eq [primary_group]
      expect(conversation.groups.count).to eq 1
      expect(conversation.group_ids).to eq [primary_group.id]

      conversation.groups.add(fundraising)

      expect(conversation.groups.all).to match_array [primary_group, fundraising]
      expect(conversation.groups.count).to eq 2
      expect(conversation.group_ids).to match_array [primary_group.id, fundraising.id]

      conversation.groups.add(electronics)

      expect(conversation.groups.all).to match_array [primary_group, fundraising, electronics]
      expect(conversation.groups.count).to eq 3
      expect(conversation.group_ids).to match_array [primary_group.id, fundraising.id, electronics.id]

      events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
      expect(events).to eq [
        [:conversation_added_group, fundraising.id],
        [:conversation_added_group, electronics.id],
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

    context 'with private groups' do
      let(:conversation){ organization.conversations.find_by_slug('recruiting') }

      it 'is private when all groups are private' do
        expect(conversation.private?).to be_truthy
      end

      it 'changes to open when a non-private group is added' do
        conversation.groups.add(electronics)
        expect(conversation.private?).to be_falsy
      end
    end

  end

  describe '#add_unless_removed' do

    it 'should add the given groups to the conversation' do
      added_groups = [electronics, fundraising]
      expected_groups = [electronics, fundraising, primary_group]
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

    context 'with private groups' do
      let(:conversation){ organization.conversations.find_by_slug('recruiting') }

      it 'is private when all groups are private' do
        expect(conversation.private?).to be_truthy
      end

      it 'changes to open when a non-private group is added' do
        conversation.groups.add_unless_removed(electronics)
        expect(conversation.private?).to be_falsy
      end
    end


  end

  describe '#remove' do
    let(:conversation){ organization.conversations.find_by_slug('parts-for-the-motor-controller') }

    context 'with more than one group' do
      before do
        conversation.groups.add fundraising
        conversation.groups.add graphic_design
      end

      it 'should remove the given groups from the conversation' do
        expect(conversation.groups.all).to match_array [electronics, fundraising, graphic_design]

        conversation.groups.remove(electronics, graphic_design)
        expect(conversation.groups.all).to eq [fundraising]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [fundraising.id]

        events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
        expect(events).to match_array [
          [:conversation_removed_group, electronics.id],
          [:conversation_removed_group, graphic_design.id]
        ]
      end
    end

    context 'with one group' do
      it 'removes the group and puts the conversation in the primary group' do
        expect(conversation.groups.all).to eq [electronics]

        conversation.groups.remove(electronics)
        expect(conversation.groups.all).to eq [primary_group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.conversation_record.group_ids_cache.length).to eq 1
        expect(conversation.group_ids).to eq [primary_group.id]

        events = conversation.events.all.last(2).map{|e| [e.event_type, e.group_id]}
        expect(events).to eq [
          [:conversation_removed_group, electronics.id],
          [:conversation_added_group,   primary_group.id],
        ]
      end
    end

    context 'when the conversation is not in the group' do
      it 'does not create any conversation events' do
        expect(conversation.groups.all).to eq [electronics]
        events_count = conversation.events.all.length

        conversation.groups.remove(fundraising)
        expect(conversation.groups.all).to eq [electronics]
        expect(conversation.groups.count).to eq 1
        expect(conversation.group_ids).to eq [electronics.id]

        expect(conversation.events.all.length).to eq events_count
      end
    end

    context 'when there is one group and it is primary' do
      let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }

      it 'does not change the groups, and creates no events' do
        expect(conversation.groups.all).to eq [primary_group]

        conversation.groups.remove(primary_group)
        expect(conversation.groups.all).to eq [primary_group]
        expect(conversation.groups.count).to eq 1
        expect(conversation.conversation_record.group_ids_cache.length).to eq 1
        expect(conversation.group_ids).to eq [primary_group.id]

        events = conversation.events.all.last(1).map{|e| e.event_type}
        expect(events).to_not eq [:conversation_removed_group]
      end
    end

  end

end
