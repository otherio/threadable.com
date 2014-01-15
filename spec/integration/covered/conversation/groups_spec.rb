require 'spec_helper'

describe Covered::Conversation::Groups do

  let(:organization) { covered.organizations.find_by_slug('raceteam') }
  let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }
  let(:all_groups) { organization.groups.all.map {|g| Covered::Group.new(covered, g.group_record)} }
  let(:groups){ conversation.groups }

  subject{ groups }

  its(:all){ should be_empty }

  describe '#add' do

    it 'should add the given groups to the conversation' do
      new_groups = all_groups.first(2)
      expect(conversation.groups.all).to eq []
      conversation.groups.add(new_groups)
      expect(conversation.groups.all).to match_array new_groups
    end

    context 'when a given group was already removed from the conversation' do

      it 'should add the given groups to the conversation' do
        group = all_groups.first
        conversation.groups.add(group)
        expect(conversation.groups.all).to eq [group]
        conversation.groups.remove(group)
        expect(conversation.groups.all).to eq []
        conversation.groups.add(group)
        expect(conversation.groups.all).to eq [group]
      end

    end

  end

  describe '#add_unless_removed' do

    it 'should add the given groups to the conversation' do
      groups = all_groups.first(2)
      expect(conversation.groups.all).to eq []
      conversation.groups.add_unless_removed(groups)
      expect(conversation.groups.all).to match_array groups
    end

    context 'when a given group was already removed from the conversation' do

      it 'should not add that group to the conversation' do
        group = all_groups.first
        conversation.groups.add_unless_removed(group)
        expect(conversation.groups.all).to eq [group]
        conversation.groups.remove(group)
        expect(conversation.groups.all).to eq []
        conversation.groups.add_unless_removed(group)
        expect(conversation.groups.all).to eq []
      end

    end

  end

  describe '#remove' do

    before do
      conversation.conversation_record.groups << all_groups.first(2).map(&:group_record)
    end

    it 'should remove the given groups from the conversation' do
      groups = conversation.groups.all
      expect(groups.length).to eq 2
      conversation.groups.remove(groups.first)
      expect(conversation.groups.all).to eq [groups.last]
    end

  end

end
