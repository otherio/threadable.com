require 'spec_helper'

feature "marking a task as done and undone" do

  before { sign_in_as 'alice@ucsd.example.com' }

  def expect_task_to_be_marked_as_done!
    within_element 'the conversation pane' do
      expect(page).to have_selector selector_for 'the mark not done button'
      expect(page).to have_text 'Alice Neilson marked this task as done moments ago'
    end
  end

  def expect_task_to_be_marked_as_not_done!
    within_element 'the conversation pane' do
      expect(page).to have_selector selector_for 'the mark as done button'
      expect(page).to have_text 'Alice Neilson marked this task as not done moments ago'
    end
  end

  scenario %(marking a task as done and undone) do

    visit my_conversation_url('raceteam','make-wooden-form-for-carbon-layup')

    expect(page).to have_selector selector_for 'the mark as done button'
    click_element 'the mark as done button'
    expect_task_to_be_marked_as_done!

    click_element 'the mark not done button'
    expect_task_to_be_marked_as_not_done!
  end
end
