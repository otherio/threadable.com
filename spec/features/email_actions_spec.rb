require 'spec_helper'

describe "Email actions" do

  let(:url){ email_action_url token: token }

  let(:user){ threadable.users.find_by_email_address!('bethany@ucsd.example.com') }
  let(:organization){ user.organizations.find_by_slug!('raceteam') }

  i_am_not_signed_in do

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
        expect(page).to be_at task_url(organization, 'my', task)
        task.reload
        expect(task).to be_done
        expect(page).to have_text "You marked #{task.subject.inspect} as done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
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
        expect(page).to be_at task_url(organization, 'my', task)
        task.reload
        expect(task).to_not be_done
        expect(page).to have_text "You marked #{task.subject.inspect} as not done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
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
        expect(page).to be_at conversation_url(organization, 'my', conversation)
        conversation.reload
        expect(conversation).to be_muted_by user
        expect(page).to have_text "You muted #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
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
        expect(page).to be_at task_url(organization, 'my', task)
        expect(task.doers).to include user
        expect(page).to have_text "You're added as a doer of #{task.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
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
        expect(page).to be_at task_url(organization, 'my', task)
        expect(task.doers).to_not include user
        expect(page).to have_text "You're no longer a doer of #{task.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
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
      end
    end

    describe "leave" do
      let(:group){ organization.groups.find_by_slug!('electronics') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'leave') }
      it "should immediately add me as a member to the group" do
        expect(group.members).to include user
        visit url
        expect(page).to have_text "You're no longer a member of the #{group.name.inspect} group"
        expect(group.members).to_not include user
      end
    end

    context "when the record cannot be found" do
      let(:token){ EmailActionToken.encrypt(999999, user.id, 'mute') }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'
      end
    end

    context "when the token is busted" do
      let(:token){ 'sadsadsa' }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'
      end
    end

  end

  i_am_signed_in_as 'bethany@ucsd.example.com' do

    describe "done" do
      let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'done') }
      it "should work immediately" do
        visit url
        expect(page).to be_at task_url(organization, 'my', task)
        task.reload
        expect(task).to be_done
        expect(page).to have_text "You marked #{task.subject.inspect} as done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "undone" do
      let(:task){ organization.tasks.find_by_slug!('layup-body-carbon') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'undone') }
      it "should work immediately" do
        visit url
        expect(page).to be_at task_url(organization, 'my', task)
        task.reload
        expect(task).to_not be_done
        expect(page).to have_text "You marked #{task.subject.inspect} as not done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "mute" do
      let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
      let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }
      it "should work immediately" do
        visit url
        expect(page).to be_at conversation_url(organization, 'my', conversation)
        conversation.reload
        expect(conversation).to be_muted_by user
        expect(page).to have_text "You muted #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "add" do
      let(:task){ organization.tasks.find_by_slug!('install-mirrors') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'add') }
      it "should work immediately" do
        visit url
        expect(page).to be_at task_url(organization, 'my', task)
        task.reload
        expect(task.doers).to include user
        expect(page).to have_text "You're added as a doer of #{task.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "remove" do
      let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'remove') }
      it "should work immediately" do
        visit url
        expect(page).to be_at task_url(organization, 'my', task)
        task.reload
        expect(task.doers).to_not include user
        expect(page).to have_text "You're no longer a doer of #{task.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "join" do
      let(:group){ organization.groups.find_by_slug!('fundraising') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'join') }
      it "should immediately add me as a member to the group" do
        expect(group.members).to_not include user
        visit url
        expect(page).to have_text "You're now a member of the #{group.name.inspect} group"
        expect(page).to be_at conversations_url(organization, 'fundraising')
        expect(group.members).to include user
      end
    end

    describe "leave" do
      let(:group){ organization.groups.find_by_slug!('electronics') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'leave') }
      it "should immediately add me as a member to the group" do
        expect(group.members).to include user
        visit url
        expect(page).to have_text "You're no longer a member of the #{group.name.inspect} group"
        expect(page).to be_at conversations_url(organization, 'electronics')
        expect(group.members).to_not include user
      end
    end

    context "when the record cannot be found" do
      let(:token){ EmailActionToken.encrypt(999999, user.id, 'mute') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    context "when the token is busted" do
      let(:token){ 'sadsadsa' }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'
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
      end
    end

    describe "undone" do
      let(:task){ organization.tasks.find_by_slug!('layup-body-carbon') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'undone') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "mute" do
      let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
      let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'mute') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "add" do
      let(:task){ organization.tasks.find_by_slug!('install-mirrors') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'add') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "remove" do
      let(:task){ organization.tasks.find_by_slug!('get-a-new-soldering-iron') }
      let(:token){ EmailActionToken.encrypt(task.id, user.id, 'remove') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "join" do
      let(:group){ organization.groups.find_by_slug!('fundraising') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'join') }
      it "should immediately add me as a member to the group" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "leave" do
      let(:group){ organization.groups.find_by_slug!('electronics') }
      let(:token){ EmailActionToken.encrypt(group.id, user.id, 'leave') }
      it "should immediately add me as a member to the group" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    context "when the record cannot be found" do
      let(:token){ EmailActionToken.encrypt(999999, user.id, 'mute') }
      it "tells me I am not authorized to do that" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    context "when the token is busted" do
      let(:token){ 'sadsadsa' }
      it "renders a server error" do
        visit url
        expect(page).to have_text 'Something went wrong'
      end
    end

  end


end
