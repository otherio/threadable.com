require 'spec_helper'

feature "Editing groups spec" do

  before do
    sign_in_as 'alice@ucsd.example.com'
    resize_window_to :large
  end

  scenario %(changing the settings of a group) do
    within selector_for('the sidebar') do
      within page.first('li.group') do
        page.find('.disclosure-triangle').click
        sleep 0.2
        expect(page).to have_text "Settings"
        click_on "Settings"
      end
    end

    expect(page).to have_text "Changes made here will affect everybody in the group. Be careful!"

    visit group_settings_url('raceteam', 'electronics')

    fill_in "description", with: "cops"
    fill_in "color", with: "#aaa333"

    click_on "Update group settings"

    expect(page).to have_text 'cops'
    expect(current_url).to eq conversations_url('raceteam', 'electronics')
  end
end
