require 'spec_helper'

feature "Adding groups spec" do

  before do
    sign_in_as 'alice@ucsd.example.com'
    resize_window_to :large
  end

  scenario %(changing the settings of a group) do
    within selector_for('the sidebar') do
      page.find('.toggle-organization-settings').click
      sleep 0.2
      expect(page).to have_text "Create new group"
      click_on "Create new group"
    end

    expect(page).to have_text "Example email subject!"

    fill_in "name", with: "Super Troops"
    within '.uk-form' do
      click_on "Create new group"
    end

    expect(page).to have_text '[Super-Tr] +Super Troops'

    expect(current_url).to eq group_members_url('raceteam', 'super-troops')
  end
end
