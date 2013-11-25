require 'spec_helper'

feature "Authentication" do

  before{ visit sign_in_url }

  scenario %(A user with an account and a password can sign in) do
    fill_in "Email", with: "alice@ucsd.covered.io"
    fill_in "Password", with: "password"
    click_button "Sign in"
    expect(page).to have_text "Projects"
    expect(current_url).to eq root_url
    expect_to_be_signed_in_as! "Alice Neilson"
  end

  scenario %(A user with an account and a password can sign in with any of their email addresses) do
    fill_in "Email", with: "yan@yansterdam.io"
    fill_in "Password", with: "password"
    click_button "Sign in"
    expect(page).to have_text "Projects"
    expect(current_url).to eq root_url
    expect_to_be_signed_in_as! "Yan Hzu"
  end

  scenario %(Failing to log in) do
    fill_in "Email", with: "beth.alameuw@gmail.com"
    fill_in "Password", with: "bullshitpassword"
    click_button "Sign in"
    # I should see the sign in form shake
    expect(page).to have_selector('.sign_in_form.shake')
  end

  scenario %(Existing user with a password forgot their password) do
    click_on "Forgot password"
    expect(page).to have_text "Recover password"
    fill_in "Email", with: "alice@ucsd.covered.io"
    click_button "Recover"
    expect(page).to have_text "We've emailed you a password reset link. Please check your email."
  end

  scenario %(Existing user without a password forgot their password) do
    click_on "Forgot password"
    expect(page).to have_text "Recover password"
    fill_in "Email", with: "jonathan@ucsd.covered.io"
    click_button "Recover"
    expect(page).to have_text "We've emailed you a link to setup your account. Please check your email."
  end

  scenario %(Unknown user forgot their password) do
    click_on "Forgot password"
    expect(page).to have_text "Recover password"
    fill_in "Email", with: "ASDSADASSDA@qwewqewq.com"
    click_button "Recover"
    expect(page).to have_text "Error! No account found with that email address"
  end

end