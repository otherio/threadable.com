require 'spec_helper'

feature "marking a task as done and undone" do

  scenario %(marking a task as done and undone) do
    sign_in_as 'alice@ucsd.covered.io'
    visit organization_conversation_url('raceteam', 'make-wooden-form-for-carbon-layup')

    click_on 'mark as done'
    expect(page).to have_text 'Notice! Task marked as done.'

    click_on 'mark as not done'
    expect(page).to have_text 'Notice! Task marked as not done.'
  end
end
