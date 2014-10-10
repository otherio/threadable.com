require 'spec_helper'

feature "mixpanel tracking" do

  scenario %(signing up), fixtures: false do
    organization_name = 'JREF'
    organization_slug = 'jref'
    name              = 'James Radi'
    email_address     = 'james.randi@jref.org'

    visit root_url

    original_mixpanel_distinct_id = mixpanel_distinct_id

    within first('.sign-up-form') do
      fill_in 'Organization name', with: organization_name
      fill_in 'Your email address',     with: email_address
      click_on 'SIGN UP'
    end

    expect(page).to have_text %(We've sent you a confirmation email.)
    expect(page).to have_text %(Please click the link in your email to complete your account request.)

    assert_tracked(mixpanel_distinct_id, 'Homepage sign up',
      email_address:     email_address,
      organization_name: organization_name,
    )

    assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "sign_up_confirmation", organization_name, email_address]
    drain_background_jobs!
    email = sent_emails.to(email_address).with_subject("Welcome to Threadable!").last
    expect(email).to be_present
    sent_emails.clear

    confirmation_url = email.link("Click here to confirm your email and create your organization")[:href]
    token = Rails.application.routes.recognize_path(confirmation_url)[:token]
    visit confirmation_url
    expect(page).to be_at_url new_organization_url(token: token)

    assert_tracked(mixpanel_distinct_id, 'New Organization Page Visited',
      sign_up_confirmation_token: true,
      organization_name:          organization_name,
      email_address:              email_address,
    )

    fill_in 'Your name',             with: name
    fill_in 'Password',              with: 'password',   match: :prefer_exact
    fill_in 'Password confirmation', with: 'password'
    click_on 'Create'

    expect(page).to be_at_url compose_conversation_url(organization_slug, 'my')

    user         = threadable.users.find_by_email_address!(email_address)
    organization = threadable.organizations.find_by_slug!(organization_slug)

    expect(mixpanel_distinct_id).to eq user.id.to_s
    expect(threadable.tracker.aliases[user.id]).to eq original_mixpanel_distinct_id

    assert_tracked(user.id, 'Sign up',
      name:                 name,
      email_address:        email_address,
      confirm_email_address: true,
    )

    assert_tracked(user.user_id, 'Organization Created',
      sign_up_confirmation_token: true,
      organization_name:          organization_name,
      email_address:              email_address,
      organization_id:            organization.id,
    )
  end

  scenario %(signing in) do
    visit root_url
    original_mixpanel_distinct_id = mixpanel_distinct_id
    expect(original_mixpanel_distinct_id.length).to be > 10
    click_on 'SIGN IN'
    within_element 'the sign in form' do
      fill_in 'Email Address', with: 'alice@ucsd.example.com'
      fill_in 'Password',      with: 'password'
      click_on 'Sign in'
    end
    expect(page).to be_at_url conversations_url('raceteam', 'my')
    user = threadable.users.find_by_email_address!('alice@ucsd.example.com')
    expect(threadable.tracker.aliases[user.id]).to be_nil
    expect(mixpanel_distinct_id).to eq user.id.to_s
    visit sign_out_url
    expect(mixpanel_distinct_id.length).to_not eq user.id
    expect(mixpanel_distinct_id.length).to be > 10
  end

end
