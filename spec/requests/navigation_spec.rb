require 'spec_helper'

describe "Navbar" do
  context "with projects" do
    let!(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:project2) { create(:project) }

    before do
      project.project_memberships.create(user: user)
      project2.project_memberships.create(user: user)
    end

    it "should include the project name" do
      visit '/'
      click_on 'Login'
      page.current_path.should == new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      visit "/#{project.slug}"

      page.should have_content project.name
    end

    it "should include a dropdown with the other projects" do
      1.should == 0
    end
  end
end
