require 'spec_helper'

describe "Email actions", :type => :feature do

  let(:tracked_event_name){ 'Email action taken' }

  let(:url){ email_action_url token: token }

  let(:user){ threadable.users.find_by_email_address!('bethany@ucsd.example.com') }
  let(:organization){ user.organizations.find_by_slug!('raceteam') }

  i_am_not_signed_in do

    # tested thoroughly via: spec/controllers/email_actions_controller_spec.rb
    #                        spec/integration/email_action_spec.rb
    context 'with secure buttons enabled' do
      before do
        user.update(secure_mail_buttons: true)
      end

      describe "follow" do
        let(:conversation){ organization.conversations.find_by_slug!('drive-trains-are-expensive') }
        let(:token){ EmailActionToken.encrypt(conversation.id, user.id, 'follow') }
        it "should ask me to sign in" do
          visit url
          expect(page).to have_text 'Hey Bethany Pattern'
          expect(page).to have_text "Please sign in to follow #{conversation.subject.inspect}"
          fill_in 'Password', with: 'password'
          click_on 'Sign in &follow'
          expect(page).to be_at_url conversation_url(organization, 'my', conversation)
          conversation.reload
          expect(conversation).to be_followed_by user
          expect(page).to have_text "You followed #{conversation.subject.inspect}"
          expect_to_be_signed_in_as! 'Bethany Pattern'
          assert_tracked(user.id, tracked_event_name, type: "follow", record_id: conversation.id)
        end
      end
    end

    context 'with secure buttons disabled' do
      before do
        user.update(secure_mail_buttons: false)
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
    end

  end

  def expect_no_email_action_taken_tracking!
    return unless trackings.select{|t| t[1] == tracked_event_name }.present?
    raise RSpec::Expectations::ExpectationNotMetError, "expected no #{tracked_event_name.inspect} trackings in:\n#{trackings.pretty_inspect}"
  end

end
