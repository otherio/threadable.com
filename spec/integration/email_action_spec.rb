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
    before do
      user.update(secure_mail_buttons: true)
    end

    describe 'mute' do
      let(:type) { :mute }
      let(:record) { organization.conversations.find_by_slug('drive-trains-are-expensive') }


      it 'mutes the conversation' do
        expect(conversation).to_not be_muted_by user
        email_action.execute!
        conversation.reload
        expect(conversation).to be_muted_by user
        assert_tracked(user.id, 'Email action taken', type: "mute", record_id: conversation.id)
      end
    end

    describe 'done' do
      let(:type) { :done }
      let(:task) { organization.tasks.find_by_slug('get-a-new-soldering-iron') }
      let(:record) { organization.tasks.find_by_slug('get-a-new-soldering-iron') }

      it 'finishes the task' do
        expect(task).to_not be_done
        email_action.execute!
        task.reload
        expect(task).to be_done
        assert_tracked(user.id, 'Email action taken', type: "done", record_id: task.id)
      end
    end

    describe 'undone' do
      let(:type) { :undone }
      let(:record) { organization.tasks.find_by_slug('layup-body-carbon') }

      it 'finishes the task' do
        expect(task).to be_done
        email_action.execute!
        task.reload
        expect(task).to_not be_done
        assert_tracked(user.id, 'Email action taken', type: "undone", record_id: task.id)
      end
    end

    describe 'follow' do
      let(:type) { :follow }
      let(:record) { organization.conversations.find_by_slug('drive-trains-are-expensive') }

      it 'follows the conversation' do
        expect(conversation).to_not be_followed_by user
        email_action.execute!
        conversation.reload
        expect(conversation).to be_followed_by user
        assert_tracked(user.id, 'Email action taken', type: "follow", record_id: conversation.id)
      end
    end

    describe 'unfollow' do
      let(:type) { :unfollow }
      let(:record) { organization.conversations.find_by_slug('drive-trains-are-expensive') }

      before do
        conversation.follow_for user
      end

      it 'unfollows the conversation' do
        expect(conversation).to be_followed_by user
        email_action.execute!
        conversation.reload
        expect(conversation).to_not be_followed_by user
        assert_tracked(user.id, 'Email action taken', type: "unfollow", record_id: conversation.id)
      end
    end

    describe 'add' do
      let(:type) { :add }
      let(:task) { organization.tasks.find_by_slug('install-mirrors') }
      let(:record) { organization.tasks.find_by_slug('install-mirrors') }

      it 'adds a doer' do
        expect(task.doers).to_not include user
        email_action.execute!
        task.reload
        expect(task.doers).to include user
        assert_tracked(user.id, 'Email action taken', type: "add", record_id: task.id)
      end
    end

    describe 'remove' do
      let(:type) { :remove }
      let(:task) { organization.tasks.find_by_slug('get-a-new-soldering-iron') }
      let(:record) { organization.tasks.find_by_slug('get-a-new-soldering-iron') }

      it 'removes a doer' do
        expect(task.doers).to include user
        email_action.execute!
        task.reload
        expect(task.doers).to_not include user
        assert_tracked(user.id, 'Email action taken', type: "remove", record_id: task.id)
      end
    end

    describe 'join' do
      let(:type) { :join }
      let(:group){ organization.groups.find_by_slug!('fundraising') }
      let(:record) { organization.groups.find_by_slug!('fundraising') }


      it 'joins the group' do
        expect(group.members).to_not include user
        email_action.execute!
        group.reload
        expect(group.members).to include user
        assert_tracked(user.id, 'Email action taken', type: "join", record_id: group.id)
      end
    end

    describe 'leave' do
      let(:type) { :leave }
      let(:record) { organization.groups.find_by_slug!('electronics') }

      it 'leaves the group' do
        expect(group.members).to include user
        email_action.execute!
        group.reload
        expect(group.members).to_not include user
        assert_tracked(user.id, 'Email action taken', type: "leave", record_id: group.id)
      end
    end

  end
end
