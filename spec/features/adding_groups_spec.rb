require 'spec_helper'

feature "Adding groups spec" do

  let(:organization){ current_user.organizations.find_by_slug('raceteam') }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end


  scenario %(changing the settings of a group) do
    within selector_for('the sidebar') do
      page.find('.toggle-organization-controls').click
      sleep 0.2
      expect(page).to have_text "Create new group"
      click_on "Create new group"
    end

    expect(page).to have_text "Example email subject!"

    fill_in "name", with: "Super Troops"
    within '.uk-form' do
      click_on "Create new group"
    end

    expect(page).to have_text 'Super Troops super-troops@raceteam.'

    expect(organization.groups.all.map(&:name)).to include "Super Troops"

    expect(current_url).to eq group_members_url('raceteam', 'super-troops')

    within(selector_for('the sidebar')) do
      within(find('.group', text: 'Super Troops')) do
        find('.disclosure-triangle').click
        click_on 'Settings'
      end
    end

    click_on 'Delete group'
    click_on 'Delete'

    within(selector_for('the sidebar')) do
      expect(page).to_not have_text 'Super Troops'
    end

    organization.groups.unload

    expect(organization.groups.all.map(&:name)).to_not include "Super Troops"
  end
end
