require 'spec_helper'

describe "Navbar" do
  context "with projects" do
    let!(:user) { create(:user, web_enabled: true) }
    let(:project) { create(:project) }
    let(:project2) { create(:project) }

    before do
      project.members << user
      project2.members << user
      sign_in_as user
      visit project_path(project)
    end

    it "should include the project email" do
      page.should have_content project.email
    end

    it "should include a dropdown with the other projects" do
      within_element 'the navbar' do
        click_link('Projects')
        within_element 'the projects dropdown menu' do
          page.should have_content project.name
          page.should have_content project2.name
          page.should have_content 'All Projects'
        end
      end
    end

  end
end
