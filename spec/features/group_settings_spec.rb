require 'spec_helper'

feature "Group settings" do

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  scenario %(changing the settings of a group) do
    within selector_for('the sidebar') do
      within 'li.group', text: 'Fundraising' do
        find('.disclosure-triangle').click
        sleep 0.2
        click_on "Settings"
      end
    end

    expect(page).to have_text "Changes made here will affect everybody in the group. Be careful!"

    fill_in "subjectTag", with: "cops"
    fill_in "color", with: "#aaa333"

    select "Hold every message from non-members"
    uncheck('Automatically add new organization members to this group')
    # check('Hold messages from senders outside of your organization')

    click_on "Update group settings"

    expect(page).to have_text 'Fundraising fundraising@raceteam.'
    expect(current_url).to eq conversations_url('raceteam', 'fundraising')

    fundraising = current_user.organizations.find_by_slug!('raceteam').groups.find_by_slug!('fundraising')
    expect(fundraising.non_member_posting).to eq 'hold'
    expect(fundraising).to_not be_auto_join
    expect(fundraising.subject_tag).to eq 'cops'
  end
end
