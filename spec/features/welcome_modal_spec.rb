require 'spec_helper'

feature "the welcome modal" do

  scenario %(when the welcome modal has not been dismissed) do
    i_am 'alice@ucsd.example.com'
    current_user.user_record.update!(dismissed_welcome_modal: false);

    sign_in!
    expect(page).to have_text 'Take a moment to learn the basics of Threadable!'
    click_on "I'll watch later"
    expect(page).to_not have_text 'Take a moment to learn the basics of Threadable!'
    expect(current_user.user_record.reload.dismissed_welcome_modal?).to be_false

    reload!
    expect(page).to have_text 'Take a moment to learn the basics of Threadable!'
    click_on "Got it, don't show this again"
    expect(page).to_not have_text 'Take a moment to learn the basics of Threadable!'
    expect(current_user.user_record.reload.dismissed_welcome_modal?).to be_true

    reload!
    expect(page).to_not have_text 'Take a moment to learn the basics of Threadable!'
  end

end
