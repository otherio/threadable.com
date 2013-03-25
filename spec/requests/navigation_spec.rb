require 'spec_helper'

describe "Navbar" do
  context "with projects" do
    let!(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:project2) { create(:project) }

    before do
      project.members << user
      project2.members << user
    end

    it "should include the project name" do
      # visit root_path
      # click_on 'Login'
      # page.current_path.should == new_user_session_path
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      visit project_path(project)

      page.should have_content project.name
    end

    it "should include a dropdown with the other projects"

  end
end
