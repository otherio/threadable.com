require 'spec_helper'

describe "Navbar" do
  context "with organizations" do
    let(:organization1) { current_user.organizations.find_by_slug('raceteam') }
    let(:organization2) { current_user.organizations.find_by_slug('sfhealth') }

    before do
      covered.current_user_id = find_user_by_email_address('alice@ucsd.example.com').id
      marcus = covered.users.find_by_email_address('marcus@sfhealth.example.com')
      current_user.organizations.find_by_slug('raceteam').members.add user: marcus
      sign_in_as 'marcus@sfhealth.example.com'
    end

    it "should include a dropdown with the other organizations" do
      visit organization_path(organization1)
      within_element 'the navbar' do
        page.should have_content organization1.email_address
        click_link('Organizations')
        within_element 'the organizations dropdown menu' do
          page.should have_content organization1.name
          page.should have_content organization2.name
          page.should have_content 'All Organizations'
        end
      end
    end

  end
end
