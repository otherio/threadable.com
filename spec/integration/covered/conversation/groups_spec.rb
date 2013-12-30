require 'spec_helper'

describe Covered::Conversation::Groups do

  let(:conversation){ covered.conversations.latest }
  let(:groups){ conversation.groups }

  subject{ groups }

  its(:all){ should be_empty }

  describe '#add' do

    it 'should add the given groups to the conversation' do
      groups = conversation.organization.groups.all.first(2)
      expect(conversation.groups.all).to eq []
      conversation.groups.add(groups)
      expect(conversation.groups.all).to match_array groups
    end

    context 'when a given group was already removed from the conversation' do

      it 'should add the given groups to the conversation' do
        group = conversation.organization.groups.all.first
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
      groups = conversation.organization.groups.all.first(2)
      expect(conversation.groups.all).to eq []
      conversation.groups.add_unless_removed(groups)
      expect(conversation.groups.all).to match_array groups
    end

    context 'when a given group was already removed from the conversation' do

      it 'should not add that group to the conversation' do
        group = conversation.organization.groups.all.first
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
      conversation.conversation_record.groups << conversation.organization.groups.all.first(2).map(&:group_record)
    end

    it 'should remove the given groups from the conversation' do
      groups = conversation.groups.all
      expect(groups.length).to eq 2
      conversation.groups.remove(groups.first)
      expect(conversation.groups.all).to eq [groups.last]
    end

  end

end
