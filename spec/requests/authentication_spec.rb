require 'spec_helper'

describe "Authentication" do

  describe "login" do
    let!(:user){ create(:user) }
    it "I can login" do
      visit '/'
      click_on 'Login'
      page.current_path.should == login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Login'
      page.should have_content "Welcome back #{user.name}"
      page.current_path.should == root_path
    end
  end

end
