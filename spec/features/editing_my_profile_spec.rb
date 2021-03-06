require 'spec_helper'

feature "Editing my profile" do

  before do
    sign_in_as 'yan@ucsd.example.com'
    visit root_url
    expect(page).to have_text 'My Conversations'
    resize_window_to :large
    find('.sidebar .toggle-user-settings').click
    click_on 'Edit profile'
  end

  scenario %(changing my name) do
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    fill_in 'user_name', with: '  '
    click_on 'Update'
    expect(page).to_not have_text %(We've updated your profile)
    expect(current_url).to eq profile_url
    expect(page).to have_field('user_name', with: '  ')
    expect(page).to have_text "can't be blank"
    expect(threadable.users.find_by_email_address!('yan@ucsd.example.com').name).to eq 'Yan Hzu'

    fill_in 'user_name', with: 'Yan Hzurself'
    click_on 'Update'
    expect(page).to have_text %(We've updated your profile)
    expect(current_url).to eq profile_url
    expect(page).to have_field('user_name', with: 'Yan Hzurself')
    expect(threadable.users.find_by_email_address!('yan@ucsd.example.com').name).to eq 'Yan Hzurself'
  end

  scenario %(changing my password) do
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    within '.expand.password-container' do
      click_on 'Expand'
    end

    fill_in 'user[current_password]',      with: 'passwor'
    fill_in 'user[password]',              with: 'supersecret', :match => :prefer_exact
    fill_in 'user[password_confirmation]', with: 'supersecrey', :match => :prefer_exact
    click_on 'Change password'
    expect(page).to have_text %(wrong password)
    expect(page).to_not have_text %(We've changed your password)

    fill_in 'user[current_password]',      with: 'password'
    fill_in 'user[password]',              with: 'supersecret', :match => :prefer_exact
    fill_in 'user[password_confirmation]', with: 'supersecrey', :match => :prefer_exact
    click_on 'Change password'
    expect(page).to have_text %(doesn't match Password)
    expect(page).to_not have_text %(We've changed your password)

    fill_in 'user[current_password]',      with: 'password'
    fill_in 'user[password]',              with: 'supersecret', :match => :prefer_exact
    fill_in 'user[password_confirmation]', with: 'supersecret', :match => :prefer_exact
    click_on 'Change password'
    expect(page).to have_text %(We've changed your password)

    expect(threadable.users.find_by_email_address!('yan@ucsd.example.com').authenticate('supersecret')).to be_truthy
  end

  scenario %(adding an email address) do
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    within '.expand.email-container' do
      click_on 'Expand'
    end
    expect(addresses).to eq Set['yan@ucsd.example.com', 'yan@yansterdam.io']

    fill_in 'my.email@example.com', with: 'yan@ucsd.example.com'
    click_on 'Add'
    expect(page).to have_text 'Address has already been taken'
    expect(addresses).to eq Set['yan@ucsd.example.com', 'yan@yansterdam.io']

    fill_in 'my.email@example.com', with: 'a@a'
    click_on 'Add'
    expect(page).to have_text 'Address is invalid'
    expect(addresses).to eq Set['yan@ucsd.example.com', 'yan@yansterdam.io']

    fill_in 'my.email@example.com', with: 'yan.hzu@example.com'
    click_on 'Add'
    expect(page).to have_text 'yan.hzu@example.com'
    expect(addresses).to eq Set['yan@ucsd.example.com', 'yan@yansterdam.io', 'yan.hzu@example.com']
    expect(confirmed_addresses).to eq Set['yan@ucsd.example.com', 'yan@yansterdam.io']
    expect(find('table.email-addresses')).to have_text 'yan.hzu@example.com'
    expect(page).to have_text "We've sent a confirmation email to yan.hzu@example.com"

    drain_background_jobs!

    expect(sent_emails.with_subject('Please confirm your email address').first).to be

    sent_emails.clear

    click_on 'resend confirmation email'
    expect(page).to have_text "We've resent a confirmation email to yan.hzu@example.com"
    drain_background_jobs!

    email = sent_emails.with_subject('Please confirm your email address').first
    expect(email).to be

    confirm_link = email.urls.find{|url| url.to_s =~ /confirm/}.to_s
    visit(confirm_link)

    expect(page).to have_text "yan.hzu@example.com has been confirmed"

    expect(confirmed_addresses).to eq Set['yan@ucsd.example.com', 'yan@yansterdam.io', 'yan.hzu@example.com']
  end

  def addresses
    current_user.email_addresses.all.map(&:address).to_set
  end

  def confirmed_addresses
    current_user.email_addresses.confirmed.map(&:address).to_set
  end

  scenario %(changing my primary email address) do
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    within '.expand.email-container' do
      click_on 'Expand'
    end
    expect( email_address_table_row('yan@ucsd.example.com') ).to have_text 'primary'
    expect( email_address_table_row('yan@yansterdam.io')   ).to have_link 'make primary'

    within email_address_table_row('yan@yansterdam.io') do
      click_on 'make primary'
    end

    expect( email_address_table_row('yan@ucsd.example.com') ).to have_link 'make primary'
    expect( email_address_table_row('yan@yansterdam.io')   ).to have_text 'primary'

    expect(page).to have_text 'yan@yansterdam.io is now your primary email address.'
    expect( current_user.reload.email_address ).to eq 'yan@yansterdam.io'
  end

  def email_address_table_row address
    find('table.email-addresses tr', text: address)
  end

end
