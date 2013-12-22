require 'spec_helper'

describe "Navbar" do
  context "with projects" do
    let(:project1) { current_user.projects.find_by_slug('raceteam') }
    let(:project2) { current_user.projects.find_by_slug('sfhealth') }

    before do
      covered.current_user_id = find_user_by_email_address('alice@ucsd.covered.io').id
      marcus = covered.users.find_by_email_address('marcus@sfhealth.example.com')
      current_user.projects.find_by_slug('raceteam').members.add user: marcus
      sign_in_as 'marcus@sfhealth.example.com'
    end

    it "should include a dropdown with the other projects" do
      visit project_path(project1)
      within_element 'the navbar' do
        page.should have_content project1.email_address
        click_link('Organizations')
        within_element 'the projects dropdown menu' do
          page.should have_content project1.name
          page.should have_content project2.name
          page.should have_content 'All Organizations'
        end
      end
    end

  end
end
