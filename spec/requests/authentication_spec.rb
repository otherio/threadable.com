require 'spec_helper'

describe "Authentication" do

  describe "login" do
    let!(:user){ create(:user) }
    it "I can login" do
      visit '/'
      click_on 'Login'
      page.current_path.should == new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_on 'Sign in'
      page.should have_content "Signed in successfully."
      page.current_path.should == root_path
    end
  end

end
