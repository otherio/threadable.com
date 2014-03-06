require 'spec_helper'

feature "requesting an account" do

  scenario %(with a new email address), fixtures: false do
    request_account! 'Zero point energy machine', 'john@the-hutchison-effect.org'
    account_request = request_account! 'Zero point energy machine', 'john@the-hutchison-effect.org'
    click_email_confirmation_link! account_request
    expect_to_be_creating_a_new_org_as_a_new_member! 'Zero point energy machine', 'john@the-hutchison-effect.org'
  end

  scenario %(with an existing user's email address), fixtures: true do
    account_request = request_account! 'Face Team', 'alice@ucsd.example.com'
    click_email_confirmation_link! account_request
    expect_to_be_creating_a_new_org_as_an_existing_member! 'Face Team', 'alice@ucsd.example.com'
  end

  def request_account! organization_name, email_address
    sent_emails.clear

    visit root_url

    within first('.sign-up-form') do
      fill_in 'Organization name', with: organization_name
      fill_in 'Email address', with: email_address
      click_on 'SIGN UP'
    end

    expect(page).to have_text 'click the link in your email'

    account_request = AccountRequest.last
    expect(account_request.organization_name).to eq organization_name
    expect(account_request.email_address    ).to eq email_address

    assert_tracked(nil, 'Account requested',{
      account_request_id: account_request.id,
      organization_name:  account_request.organization_name,
      email_address:      account_request.email_address,
    })

    assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "account_request_confirmation", account_request.id]

    return account_request
  end

  def click_email_confirmation_link! account_request
    drain_background_jobs!

    email = sent_emails.to(account_request.email_address).with_subject("Threadable account request").last
    expect(email).to be_present

    visit email.link("Click here to confirm your account request")[:href]

    account_request.reload
    expect(account_request).to be_confirmed

    assert_tracked(nil, 'Account request confirmed',{
      account_request_id: account_request.id,
      organization_name:  account_request.organization_name,
      email_address:      account_request.email_address,
    })
  end

  def expect_to_be_creating_a_new_org_as_a_new_member! organization_name, email_address
    expect(page).to be_at_url new_organization_url(organization_name: organization_name)
    expect(page).to have_field('Organization name', with: organization_name)
    expect(page).to have_field('Your name', with: "")
    expect(page).to have_field('Your email address', with: email_address, disabled: true)
    expect(page).to have_field('Password', :match => :prefer_exact)
    expect(page).to have_field('Password confirmation')
  end

  def expect_to_be_creating_a_new_org_as_an_existing_member! organization_name, email_address
    expect(page).to be_at_url new_organization_url(organization_name: organization_name)
    expect(page).to have_field('Organization name', with: organization_name)
    expect(page).to_not have_field('Your name')
    expect(page).to_not have_field('Your email address', disabled: true)
    expect(page).to_not have_field('Password', :match => :prefer_exact)
    expect(page).to_not have_field('Password confirmation')
  end

end
