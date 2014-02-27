require "spec_helper"

feature "web enabling account" do

  let(:user){ threadable.users.find_by_email_address! 'yan@ucsd.example.com' }

  scenario "Users who are not web enabled should be able web enable their account" do
    visit sign_in_url
    resize_window_to :large
    click_link 'Forgot Password'
    fill_in 'Email Address', with: user.email_address
    click_button 'Recover'
    expect(page).to have_text "We've emailed you a password reset link."

    drain_background_jobs!

    email = sent_emails.to(user.email_address).with_subject("Reset your password!").first
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
    expect(page).to have_text "Yan Hzu"

    page.find('.sidebar .toggle-user-settings').click
    sleep 0.2 # this waits for the css transition - Jared
    click_link 'Sign out'
    expect(page).to be_at_url root_url

    visit sign_in_url
    fill_in 'Email Address', with: user.email_address
    fill_in 'Password', with: 'p@$$w0rd'
    click_button 'Sign in'

    within '.sidebar .user-controls' do
      expect(page).to have_text user.name
    end
    expect(page).to have_text "carbon"
  end

end
