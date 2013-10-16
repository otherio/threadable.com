require 'spec_helper'

describe "Authentication" do

  describe "sign in/out" do

    let!(:user){ User.where(name: "Alice Neilson").first! }

    it "I can sign in and sign out" do
      visit sign_in_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'password'
      click_button 'Sign in'
      page.should have_content user.name
      page.current_path.should == root_path
      within selector_for('the navbar') do
        click_on user.name
        click_on 'Sign out'
      end
      page.should_not have_content user.name
      page.current_path.should == root_path
    end

  end

end
