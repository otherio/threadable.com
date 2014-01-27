require 'spec_helper'

describe "Email actions" do

  let(:url){ email_action_url token: EmailActionToken.encrypt(conversation.id, user.id, action) }

  let(:user){ covered.users.find_by_email_address!('bethany@ucsd.example.com') }
  let(:conversation){ user.organizations.find_by_slug!('raceteam').conversations.find_by_slug!('layup-body-carbon') }

  i_am_not_signed_in do

    describe "done" do
      let(:action){ 'done' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Hey Bethany Pattern'
        expect(page).to have_text 'Please sign in to mark "layup body carbon" as done'
        fill_in 'Password', with: 'password'
        click_on 'Sign in &done'
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation).to be_done
        expect(page).to have_text "You marked #{conversation.subject.inspect} as done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "undone" do
      let(:action){ 'undone' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Hey Bethany Pattern'
        expect(page).to have_text 'Please sign in to mark "layup body carbon" as not done'
        fill_in 'Password', with: 'password'
        click_on 'Sign in &undone'
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation).to_not be_done
        expect(page).to have_text "You marked #{conversation.subject.inspect} as not done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "mute" do
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Hey Bethany Pattern'
        expect(page).to have_text 'Please sign in to mute "layup body carbon"'
        fill_in 'Password', with: 'password'
        click_on 'Sign in &mute'
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation).to be_muted_by user
        expect(page).to have_text "You muted #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "add" do
      let(:action){ 'add' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Hey Bethany Pattern'
        expect(page).to have_text 'Please sign in to add yourself as a doer of "layup body carbon"'
        fill_in 'Password', with: 'password'
        click_on 'Sign in &add'
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation.doers).to include user
        expect(page).to have_text "You're added as a doer of #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "remove" do
      let(:action){ 'remove' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Hey Bethany Pattern'
        expect(page).to have_text 'Please sign in to remove yourself as a doer of "layup body carbon"'
        fill_in 'Password', with: 'password'
        click_on 'Sign in &remove'
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation.doers).to_not include user
        expect(page).to have_text "You're no longer a doer of #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    context "when the conversation cannot be found" do
      let(:url){ email_action_url token: EmailActionToken.encrypt(999999, user.id, action) }
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Something went wrong'
      end
    end

    context "when the token is busted" do
      let(:url){ email_action_url token: 'sadsadsa' }
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Something went wrong'
      end
    end

  end

  i_am_signed_in_as 'bethany@ucsd.example.com' do

    describe "done" do
      let(:action){ 'done' }
      it "should ask me to sign in" do
        visit url
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation).to be_done
        expect(page).to have_text "we've marked #{conversation.subject.inspect} as done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "undone" do
      let(:action){ 'undone' }
      it "should ask me to sign in" do
        visit url
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation).to_not be_done
        expect(page).to have_text "we've marked #{conversation.subject.inspect} as not done"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "mute" do
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation).to be_muted_by user
        expect(page).to have_text "we've muted #{conversation.subject.inspect} for you"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "add" do
      let(:action){ 'add' }
      it "should ask me to sign in" do
        visit url
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation.doers).to include user
        expect(page).to have_text "we've added you as a doer of the task #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    describe "remove" do
      let(:action){ 'remove' }
      it "should ask me to sign in" do
        visit url
        expect(page).to be_at conversation_url(conversation.organization, 'my', conversation)
        conversation.reload
        expect(conversation.doers).to_not include user
        expect(page).to have_text "we've removed you from the doers of the task #{conversation.subject.inspect}"
        expect_to_be_signed_in_as! 'Bethany Pattern'
      end
    end

    context "when the conversation cannot be found" do
      let(:url){ email_action_url token: EmailActionToken.encrypt(999999, user.id, action) }
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    context "when the token is busted" do
      let(:url){ email_action_url token: 'sadsadsa' }
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Something went wrong'
      end
    end

  end

  i_am_signed_in_as 'mquinn@sfhealth.example.com' do

    describe "done" do
      let(:action){ 'done' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "undone" do
      let(:action){ 'undone' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "mute" do
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "add" do
      let(:action){ 'add' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    describe "remove" do
      let(:action){ 'remove' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    context "when the conversation cannot be found" do
      let(:url){ email_action_url token: EmailActionToken.encrypt(999999, user.id, action) }
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'You are not authorized to take that action'
      end
    end

    context "when the token is busted" do
      let(:url){ email_action_url token: 'sadsadsa' }
      let(:action){ 'mute' }
      it "should ask me to sign in" do
        visit url
        expect(page).to have_text 'Something went wrong'
      end
    end

  end


end
