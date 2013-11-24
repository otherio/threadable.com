require 'spec_helper'

feature "Adding doers to a task" do

  scenario %(adding doers to a task) do
    sign_in_as 'alice@ucsd.covered.io'
    visit project_conversation_url('raceteam', 'make-wooden-form-for-carbon-layup')

    click_on 'add/remove other'
    click_on 'Yan Hzu'
    expect(page).to have_text 'Notice! Yan Hzu have been added as a doer.'

    click_on 'add/remove other'
    click_on 'Yan Hzu'
    expect(page).to have_text 'Notice! Yan Hzu have been removed as a doer.'
  end
end
