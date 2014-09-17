require 'spec_helper'

describe EmailAction, :type => :request do

  let(:organization){ user.organizations.find_by_slug!('raceteam') }
  let(:user){ threadable.users.find_by_email_address!('bethany@ucsd.example.com') }
  let(:task) { organization.tasks.find_by_slug('layup-body-carbon') }
  let(:conversation) { organization.conversations.find_by_slug('drive-trains-are-expensive') }
  let(:group) { organization.groups.find_by_slug('electronics') }

  describe '#record' do
    examples = {
      done:     { record_type: :task,         returned_class: Threadable::Task },
      undone:   { record_type: :task,         returned_class: Threadable::Task },
      mute:     { record_type: :conversation, returned_class: Threadable::Conversation },
      unmute:   { record_type: :conversation, returned_class: Threadable::Conversation },
      follow:   { record_type: :conversation, returned_class: Threadable::Conversation },
      unfollow: { record_type: :conversation, returned_class: Threadable::Conversation },
      add:      { record_type: :task,         returned_class: Threadable::Task },
      remove:   { record_type: :task,         returned_class: Threadable::Task },
      join:     { record_type: :group,        returned_class: Threadable::Group },
      leave:    { record_type: :group,        returned_class: Threadable::Group },
    }

    examples.each do |type, params|
      context "when given #{type}" do
        subject{ described_class.new(threadable, type, user.id, self.send(params[:record_type]).id).record }
        it { is_expected.to be_a params[:returned_class] }
      end
    end

    context 'with a private group' do
      let(:group_record) { ::Group.where(email_address_tag: 'leaders').first }
      let(:group) { Threadable::Group.new(threadable, group_record) }

      it 'does not allow joining' do
        email_action = described_class.new(threadable, :join, user.id, group_record.id)
        expect(email_action.record).to be_nil
      end

      it 'does allow leaving' do
        group_record.members << user.user_record
        email_action = described_class.new(threadable, :leave, user.id, group_record.id)
        expect(email_action.record).to be_a Threadable::Group
      end
    end

  end

  describe '#execute!' do
    let(:email_action) { described_class.new(threadable, type, user.id, record.id) }

    describe 'mute' do
      let(:type) { :mute }
      let(:record) { organization.conversations.find_by_slug('drive-trains-are-expensive') }

      it 'mutes the conversation' do
        email_action.execute!
        conversation.reload
        expect(conversation).to be_muted_by user
      end
    end

  end

end
