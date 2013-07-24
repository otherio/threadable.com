require 'spec_helper'

describe "invitations" do

  context "inviting someone to a project" do

    let!(:user){ User.where(name: "Alice Neilson").first! }

    before do
      Devise::Mailer.stub(:confirmation_instructions).and_return{|*args|
        binding.pry
      }
    end

    def invited_user
      User.with_email('steve@apple.com').first
    end

    it "should only send them one email" do
      expect(invited_user).to be_blank
      expect(ActionMailer::Base.deliveries).to be_empty
      login_via_capybara_as user
      expect(ActionMailer::Base.deliveries).to be_empty
      click_on 'UCSD Electric Racing'
      click_on 'Invite'
      within('.modal') do
        fill_in 'Name', with: 'Steve Jobs'
        fill_in 'Email', with: 'steve@apple.com'
        click_on 'Invite'
      end
      page.should have_content "Hey! Steve Jobs <steve@apple.com> was added to this project."
      expect(invited_user).to be_present
      expect(ActionMailer::Base.deliveries.length).to eq 1

      email_body = ActionMailer::Base.deliveries.last.body.to_s
      subscribe_url = URI.extract(email_body).find{|x| x.include? '/subscribe/'}

      page.reset!
      visit subscribe_url

      page.should have_content "We just subscribed Steve Jobs to UCSD Electric Racing"

      invited_user.should be_confirmed
    end

  end

end
