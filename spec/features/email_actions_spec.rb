require 'spec_helper'

describe "Email actions" do

  let(:tracked_event_name){ 'Email action taken' }

  let(:url){ email_action_url token: token }

  let(:user){ threadable.users.find_by_email_address!('bethany@ucsd.example.com') }
  let(:organization){ user.organizations.find_by_slug!('raceteam') }

  i_am_not_signed_in do

    # TODO: explore all the permutations here with unit tests instead, because
    #       this runs really fucking slow. :(
    context 'with secure buttons enabled' do
      before do
        user.update(secure_mail_buttons: true)
      end

      describe "done" do
        let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'done') }
        it "should ask me to sign in" do
          expect(task).to_not be_done
          visit url
          expect(page).to have_text 'Hey Bethany Pattern'
          expect(page).to have_text "Please sign in to mark #{task.subject.inspect} as done"
          fill_in 'Password', with: 'password'
          click_on 'Sign in &done'
          expect(page).to be_at_url task_url(organization, 'my', task)
          task.reload
          expect(task).to be_done
          expect(page).to have_text "You marked #{task.subject.inspect} as done"
          expect_to_be_signed_in_as! 'Bethany Pattern'
          assert_tracked(user.id, tracked_event_name, type: "done", record_id: task.id)
        end
      end

      describe "undone" do
        let(:task){ organization.tasks.find_by_slug!('layup-body-carbon') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'undone') }
        it "should ask me to sign in" do
          expect(task).to be_done
          visit url
          expect(page).to have_text 'Hey Bethany Pattern'
          expect(page).to have_text "Please sign in to mark #{task.subject.inspect} as not done"
          fill_in 'Password', with: 'password'
          click_on 'Sign in &undone'
          expect(page).to be_at_url task_url(organization, 'my', task)
          task.reload
          expect(task).to_not be_done
          expect(page).to have_text "You marked #{task.subject.inspect} as not done"
          expect_to_be_signed_in_as! 'Bethany Pattern'
          assert_tracked(user.id, tracked_event_name, type: "undone", record_id: task.id)
        end
      end

      describe "mute" do
        let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
        let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }
        it "should ask me to sign in" do
          visit url
          expect(page).to have_text 'Hey Bethany Pattern'
          expect(page).to have_text "Please sign in to mute #{conversation.subject.inspect}"
          fill_in 'Password', with: 'password'
          click_on 'Sign in &mute'
          expect(page).to be_at_url conversation_url(organization, 'my', conversation)
          conversation.reload
          expect(conversation).to be_muted_by user
          expect(page).to have_text "You muted #{conversation.subject.inspect}"
          expect_to_be_signed_in_as! 'Bethany Pattern'
          assert_tracked(user.id, tracked_event_name, type: "mute", record_id: conversation.id)
        end
      end

      describe "add" do
        let(:task){ organization.tasks.find_by_slug!('install-mirrors') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'add') }
        it "should ask me to sign in" do
          expect(task.doers).to_not include user
          visit url
          expect(page).to have_text 'Hey Bethany Pattern'
          expect(page).to have_text "Please sign in to add yourself as a doer of #{task.subject.inspect}"
          fill_in 'Password', with: 'password'
          click_on 'Sign in &add'
          expect(page).to be_at_url task_url(organization, 'my', task)
          expect(task.doers).to include user
          expect(page).to have_text "You're added as a doer of #{task.subject.inspect}"
          expect_to_be_signed_in_as! 'Bethany Pattern'
          assert_tracked(user.id, tracked_event_name, type: "add", record_id: task.id)
        end
      end

      describe "remove" do
        let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'remove') }
        it "should ask me to sign in" do
          expect(task.doers).to include user
          visit url
          expect(page).to have_text 'Hey Bethany Pattern'
          expect(page).to have_text "Please sign in to remove yourself as a doer of #{task.subject.inspect}"
          fill_in 'Password', with: 'password'
          click_on 'Sign in &remove'
          expect(page).to be_at_url task_url(organization, 'my', task)
          expect(task.doers).to_not include user
          expect(page).to have_text "You're no longer a doer of #{task.subject.inspect}"
          expect_to_be_signed_in_as! 'Bethany Pattern'
          assert_tracked(user.id, tracked_event_name, type: "remove", record_id: task.id)
        end
      end

    end

    context 'with secure buttons disabled' do
      before do
        user.update(secure_mail_buttons: false)
      end

      describe "done" do
        let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'done') }
        it "should immediately mark the task as done" do
          expect(task).to_not be_done
          visit url
          expect(page).to have_text "You marked #{task.subject.inspect} as done"
          task.reload
          expect(task).to be_done
          assert_tracked(user.id, tracked_event_name, type: "done", record_id: task.id)

          click_on "Mark #{task.subject.inspect} as not done"
          expect(page).to have_text "You marked #{task.subject.inspect} as not done"
          task.reload
          expect(task).to_not be_done
          assert_tracked(user.id, tracked_event_name, type: "undone", record_id: task.id)
        end
      end

      describe "undone" do
        let(:task){ organization.tasks.find_by_slug!('layup-body-carbon') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'undone') }
        it "should immediately mark the task as undone" do
          expect(task).to be_done
          visit url
          expect(page).to have_text "You marked #{task.subject.inspect} as not done"
          task.reload
          expect(task).to_not be_done
          assert_tracked(user.id, tracked_event_name, type: "undone", record_id: task.id)

          click_on "Mark #{task.subject.inspect} as done"
          expect(page).to have_text "You marked #{task.subject.inspect} as done"
          task.reload
          expect(task).to be_done
          assert_tracked(user.id, tracked_event_name, type: "done", record_id: task.id)
        end
      end

      describe "mute" do
        let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
        let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }
        it "should immediately mute the conversation" do
          visit url
          expect(page).to have_text "You muted #{conversation.subject.inspect}"
          conversation.reload
          expect(conversation).to be_muted_by user
          assert_tracked(user.id, tracked_event_name, type: "mute", record_id: conversation.id)
        end
      end

      describe "add" do
        let(:task){ organization.tasks.find_by_slug!('install-mirrors') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'add') }
        it "should immediately add me as a doer of the task" do
          expect(task.doers).to_not include user
          visit url
          expect(page).to have_text "You're added as a doer of #{task.subject.inspect}"
          expect(task.doers).to include user
          assert_tracked(user.id, tracked_event_name, type: "add", record_id: task.id)

          click_on "Remove yourself as a doer of #{task.subject.inspect}"
          expect(page).to have_text "You're no longer a doer of #{task.subject.inspect}"
          expect(task.doers).to_not include user
          assert_tracked(user.id, tracked_event_name, type: "remove", record_id: task.id)
        end
      end

      describe "remove" do
        let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
        let(:token){ EmailActionToken.encrypt(task.id, user.id, 'remove') }
        it "should immediately remove me from the doers of the task" do
          expect(task.doers).to include user
          visit url
          expect(page).to have_text "You're no longer a doer of #{task.subject.inspect}"
          expect(task.doers).to_not include user
          assert_tracked(user.id, tracked_event_name, type: "remove", record_id: task.id)

          click_on "Add yourself as a doer of #{task.subject.inspect}"
          expect(page).to have_text "You're added as a doer of #{task.subject.inspect}"
          expect(task.doers).to include user
          assert_tracked(user.id, tracked_event_name, type: "add", record_id: task.id)
        end
      end
    end

    describe "join" do
      let(:group){ organization.groups.find_by_slug!('fundraising') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'join') }
      it "should immediately add me as a member to the group" do
        expect(group.members).to_not include user
        visit url
        expect(page).to have_text "You're now a member of the #{group.name.inspect} group"
        expect(group.members).to include user
        assert_tracked(user.id, tracked_event_name, type: "join", record_id: group.id)

        click_on "Leave #{group.name.inspect}"
        expect(page).to have_text "You're no longer a member of the #{group.name.inspect} group"
        expect(group.members).to_not include user
        assert_tracked(user.id, tracked_event_name, type: "leave", record_id: group.id)
      end
    end

    describe "leave" do
      let(:group){ organization.groups.find_by_slug!('electronics') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'leave') }
      it "should immediately remove me as a member to the group" do
        expect(group.members).to include user
        visit url
        expect(page).to have_text "You're no longer a member of the #{group.name.inspect} group"
        expect(group.members).to_not include user
        assert_tracked(user.id, tracked_event_name, type: "leave", record_id: group.id)

        click_on "Rejoin #{group.name.inspect}"
        expect(page).to have_text "You're now a member of the #{group.name.inspect} group"
        expect(group.members).to include user
        assert_tracked(user.id, tracked_event_name, type: "join", record_id: group.id)
      end
    end

    context "when the record cannot be found" do
      let(:token){ EmailActionToken.encrypt(999999, user.id, 'mute') }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'

        expect_no_email_action_taken_tracking!
      end
    end

    context "when the token is busted" do
      let(:token){ 'sadsadsa' }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'
        expect_no_email_action_taken_tracking!
      end
    end

  end

  i_am_signed_in_as 'bethany@ucsd.example.com' do

    describe "done" do
      let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'done') }
      it "should work immediately" do
        visit url
        expect(page).to be_at_url task_url(organization, 'my', task)
        task.reload
        expect(task).to be_done
        expect(page).to have_text "You marked #{task.subject.inspect} as done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
        assert_tracked(threadable.current_user.id, tracked_event_name, type: "done", record_id: task.id)
      end
    end

    describe "undone" do
      let(:task){ organization.tasks.find_by_slug!('layup-body-carbon') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'undone') }
      it "should work immediately" do
        visit url
        expect(page).to be_at_url task_url(organization, 'my', task)
        task.reload
        expect(task).to_not be_done
        expect(page).to have_text "You marked #{task.subject.inspect} as not done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
        assert_tracked(threadable.current_user.id, tracked_event_name, type: "undone", record_id: task.id)
      end
    end

    describe "mute" do
      let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
      let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }
      it "should work immediately" do
        visit url
        expect(page).to be_at_url conversation_url(organization, 'my', conversation)
        conversation.reload
        expect(conversation).to be_muted_by user
        expect(page).to have_text "You muted #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
        assert_tracked(threadable.current_user.id, tracked_event_name, type: "mute", record_id: conversation.id)
      end
    end

    describe "add" do
      let(:task){ organization.tasks.find_by_slug!('install-mirrors') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'add') }
      it "should work immediately" do
        visit url
        expect(page).to be_at_url task_url(organization, 'my', task)
        task.reload
        expect(task.doers).to include user
        expect(page).to have_text "You're added as a doer of #{task.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
        assert_tracked(threadable.current_user.id, tracked_event_name, type: "add", record_id: task.id)
      end
    end

    describe "remove" do
      let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'remove') }
      it "should work immediately" do
        visit url
        expect(page).to be_at_url task_url(organization, 'my', task)
        task.reload
        expect(task.doers).to_not include user
        expect(page).to have_text "You're no longer a doer of #{task.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
        assert_tracked(threadable.current_user.id, tracked_event_name, type: "remove", record_id: task.id)
      end
    end

    describe "join" do
      let(:group){ organization.groups.find_by_slug!('fundraising') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'join') }
      it "should immediately add me as a member to the group" do
        expect(group.members).to_not include user
        visit url
        expect(page).to have_text "You're now a member of the #{group.name.inspect} group"
        expect(page).to be_at_url conversations_url(organization, 'fundraising')
        expect(group.members).to include user
        assert_tracked(threadable.current_user.id, tracked_event_name, type: "join", record_id: group.id)
      end
    end

    describe "leave" do
      let(:group){ organization.groups.find_by_slug!('electronics') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'leave') }
      it "should immediately remove me as a member to the group" do
        expect(group.members).to include user
        visit url
        expect(page).to have_text "You're no longer a member of the #{group.name.inspect} group"
        expect(page).to be_at_url conversations_url(organization, 'electronics')
        expect(group.members).to_not include user
        assert_tracked(threadable.current_user.id, tracked_event_name, type: "leave", record_id: group.id)
      end
    end

    context "when the record cannot be found" do
      let(:token){ EmailActionToken.encrypt(999999, user.id, 'mute') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    context "when the token is busted" do
      let(:token){ 'sadsadsa' }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'
        expect_no_email_action_taken_tracking!
      end
    end

  end

  i_am_signed_in_as 'mquinn@sfhealth.example.com' do

    describe "done" do
      let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'done') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    describe "undone" do
      let(:task){ organization.tasks.find_by_slug!('layup-body-carbon') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'undone') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    describe "mute" do
      let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
      let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    describe "add" do
      let(:task){ organization.tasks.find_by_slug!('install-mirrors') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'add') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    describe "remove" do
      let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'remove') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    describe "join" do
      let(:group){ organization.groups.find_by_slug!('fundraising') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'join') }
      it "should immediately add me as a member to the group" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    describe "leave" do
      let(:group){ organization.groups.find_by_slug!('electronics') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'leave') }
      it "should immediately remove me as a member to the group" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    context "when the record cannot be found" do
      let(:token){ EmailActionToken.encrypt(999999, user.id, 'mute') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
        expect_no_email_action_taken_tracking!
      end
    end

    context "when the token is busted" do
      let(:token){ 'sadsadsa' }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'
        expect_no_email_action_taken_tracking!
      end
    end

  end

  def expect_no_email_action_taken_tracking!
    return unless trackings.select{|t| t[1] == tracked_event_name }.present?
    raise RSpec::Expectations::ExpectationNotMetError, "expected no #{tracked_event_name.inspect} trackings in:\n#{trackings.pretty_inspect}"
  end

end
