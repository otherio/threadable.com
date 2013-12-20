require 'spec_helper'

feature "Editing my profile" do

  before do
    sign_in_as 'yan@ucsd.covered.io'
    visit root_url
    click_on current_user.name
    click_on 'Profile'
  end

  scenario %(changing my name) do
    fill_in 'Name', with: '  '
    click_on 'Update'
    expect(page).to_not have_text %(Notice! We've updated your profile)
    expect(current_url).to eq profile_url
    expect(page).to have_field('Name', with: '  ')
    expect(page).to have_text "can't be blank"
    expect(covered.users.find_by_email_address!('yan@ucsd.covered.io').name).to eq 'Yan Hzu'

    fill_in 'Name', with: 'Yan Hzurself'
    click_on 'Update'
    expect(page).to have_text %(Notice! We've updated your profile)
    expect(current_url).to eq profile_url
    expect(page).to have_field('Name', with: 'Yan Hzurself')
    expect(covered.users.find_by_email_address!('yan@ucsd.covered.io').name).to eq 'Yan Hzurself'
  end

  scenario %(changing my password) do
    fill_in 'Current password',      with: 'passwor'
    fill_in 'Password',              with: 'supersecret', :match => :prefer_exact
    fill_in 'Password confirmation', with: 'supersecrey', :match => :prefer_exact
    click_on 'Change password'
    expect(page).to have_text %(wrong password)
    expect(page).to_not have_text %(We've changed your password)

    fill_in 'Current password',      with: 'password'
    fill_in 'Password',              with: 'supersecret', :match => :prefer_exact
    fill_in 'Password confirmation', with: 'supersecrey', :match => :prefer_exact
    click_on 'Change password'
    expect(page).to have_text %(doesn't match Password)
    expect(page).to_not have_text %(We've changed your password)

    fill_in 'Current password',      with: 'password'
    fill_in 'Password',              with: 'supersecret', :match => :prefer_exact
    fill_in 'Password confirmation', with: 'supersecret', :match => :prefer_exact
    click_on 'Change password'
    expect(page).to_not have_text %(We've changed your password)

    expect(covered.users.find_by_email_address!('yan@ucsd.covered.io').authenticate('supersecret')).to be_true
  end

  scenario %(adding an email address) do
    expect(addresses).to eq Set['yan@ucsd.covered.io', 'yan@yansterdam.io']

    fill_in 'my.email@example.com', with: 'yan@ucsd.covered.io'
    click_on 'Add'
    expect(page).to have_text 'Error! Address has already been taken'
    expect(addresses).to eq Set['yan@ucsd.covered.io', 'yan@yansterdam.io']

    fill_in 'my.email@example.com', with: 'a@a'
    click_on 'Add'
    expect(page).to have_text 'Error! Address is invalid'
    expect(addresses).to eq Set['yan@ucsd.covered.io', 'yan@yansterdam.io']

    fill_in 'my.email@example.com', with: 'yan.hzu@example.com'
    click_on 'Add'
    expect(page).to have_text 'yan.hzu@example.com'
    expect(addresses).to eq Set['yan@ucsd.covered.io', 'yan@yansterdam.io', 'yan.hzu@example.com']
  end

  def addresses
    current_user.email_addresses.all.map(&:address).to_set
  end

  scenario %(changing my primary email address) do
    expect( email_address_table_row('yan@ucsd.covered.io') ).to have_text 'primary'
    expect( email_address_table_row('yan@yansterdam.io')   ).to have_link 'make primary'

    within email_address_table_row('yan@yansterdam.io') do
      click_on 'make primary'
    end

    expect( email_address_table_row('yan@ucsd.covered.io') ).to have_link 'make primary'
    expect( email_address_table_row('yan@yansterdam.io')   ).to have_text 'primary'

    expect(page).to have_text 'Notice! yan@yansterdam.io is now your primary email address.'
    expect( current_user.reload.email_address ).to eq 'yan@yansterdam.io'
  end

  def email_address_table_row address
    find('table.email-addresses tr', text: address)
  end

end
