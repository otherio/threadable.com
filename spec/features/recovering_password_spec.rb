require "spec_helper"

feature "recovering password" do

  scenario "Users who lose their password should be able recover their account" do
    i_am 'alice@ucsd.example.com'

    visit '/'
    resize_window_to :large
    expect(page).to have_text "Forgot Password"
    click_link 'Forgot Password'
    fill_in 'Email Address', with: current_user.email_address
    click_button 'Recover'
    expect(page).to have_text "We've emailed you a password reset link."

    drain_background_jobs!

    email = sent_emails.to(current_user.email_address).with_subject("Reset your password!").first
    expect(email).to be_present

    link = email.link("Click here to reset your password")
    expect(link).to be_present

    visit link[:href]

    fill_in 'user[password]', with: 'p@$$w0rd'
    fill_in 'user[password_confirmation]', with: 'sdfddsfs'
    click_button 'Update'
    expect(page).to have_text "doesn't match Password"

    fill_in 'user[password]', with: 'p@$$w0rd'
    fill_in 'user[password_confirmation]', with: 'p@$$w0rd'
    click_button 'Update'
    expect(page).to have_text "Alice Neilson"

    page.find('.sidebar .user-controls .toggle-user-settings').click
    sleep 0.2
    click_link 'Sign out'
    expect(page).to have_text "No password yet?"

    fill_in 'Email Address', with: current_user.email_address
    fill_in 'Password', with: 'p@$$w0rd'
    click_button 'Sign in'

    within '.sidebar .user-controls' do
      expect(page).to have_text current_user.name
    end
  end
end
