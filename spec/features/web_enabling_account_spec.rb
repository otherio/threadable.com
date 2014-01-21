require "spec_helper"

feature "web enabling account" do

  let(:user){ covered.users.find_by_email_address! 'yan@ucsd.example.com' }

  scenario "Users who are not web enabled should be able web enable their account" do
    visit '/'
    click_link 'Forgot Password'
    fill_in 'Email', with: user.email_address
    click_button 'Recover'
    expect(page).to have_text "We've emailed you instructions for how to set your password. Thanks!"

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

    click_link 'Sign Out'
    expect(page).to have_text "No password yet?"

    fill_in 'Email', with: user.email_address
    fill_in 'Password', with: 'p@$$w0rd'
    click_button 'Sign in'

    within '.current-user-controls' do
      expect(page).to have_text user.name
    end
  end

end
