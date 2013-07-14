require 'spec_helper'

describe "Authentication" do

  describe "login/logout" do

    let!(:user){ User.where(name: "Alice Neilson").first! }

    it "I can login and logout" do
      # visit '/users/sign_in'
      # click_on 'Login'
      # page.current_path.should == new_user_session_path
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'password'
      click_button 'Sign in'
      page.should have_content user.name
      page.current_path.should == root_path
      within selector_for('the navbar') do
        click_on user.name
        click_on 'Logout'
      end
      page.should_not have_content user.name
      page.current_path.should == root_path
    end
  end


end
