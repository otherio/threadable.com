require 'spec_helper'

feature "marking a task as done and undone" do

  before { sign_in_as 'alice@ucsd.example.com' }

  scenario %(marking a task as done and undone) do

    visit my_conversation_url('raceteam','make-wooden-form-for-carbon-layup')

    within_element 'the conversation pane' do
      expect(page).to have_selector selector_for 'the mark as done button'
      click_element 'the mark as done button'

      expect(page).to have_selector selector_for 'the mark not done button'
      expect(page).to have_text 'Alice Neilson marked this task as done moments ago'
      click_element 'the mark not done button'

      expect(page).to have_selector selector_for 'the mark as done button'
      expect(page).to have_text 'Alice Neilson marked this task as not done moments ago'
    end
  end
end
