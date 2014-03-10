require 'spec_helper'

feature "signing up" do

  let :members do
    [
      ['Sathya Sai Baba', 'sathya@saibaba.me'],
      ['Edgar Cayce',     'edgar@edgarcayce.org'],
      ['Deepak Chopra',   'deepak@chopra.me'],
    ]
  end

  def sign_up! organization_name, email_address
    visit root_url
    # assert_tracked(nil, 'Homepage visited') # this is client side tracked now to avoid uptime requests padding our demoninator

    within first('.sign-up-form') do
      fill_in 'Organization name', with: organization_name
      fill_in 'Email address',     with: email_address
      click_on 'SIGN UP'
    end

    wait_until_expectation do
      assert_tracked(nil, 'Homepage sign up',{
        email_address:     email_address,
        organization_name: organization_name,
      })
    end
  end

  scenario %(as new user), fixtures: false do
    sign_out!
    sign_up! 'Zero point energy machine', 'john@the-hutchison-effect.org'

    expect(page).to have_text %(We've sent you a confirmation email.)
    expect(page).to have_text %(Please click the link in your email to complete your account request.)

    assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "sign_up_confirmation", 'Zero point energy machine', 'john@the-hutchison-effect.org']
    drain_background_jobs!
    email = sent_emails.to('john@the-hutchison-effect.org').with_subject("Welcome to Threadable!").last
    expect(email).to be_present
    sent_emails.clear

    confirmation_url = email.link("Click here to confirm your email and create your organization")[:href]
    token = Rails.application.routes.recognize_path(confirmation_url)[:token]
    visit confirmation_url
    expect(page).to be_at_url new_organization_url(token: token)

    expect(threadable.email_addresses.find_by_address('john@the-hutchison-effect.org')).to be_confirmed

    assert_tracked(nil, 'New Organization Page Visited',
      sign_up_confirmation_token: true,
      organization_name: 'Zero point energy machine',
      email_address: 'john@the-hutchison-effect.org',
    )

    expect(page).to have_field 'Organization name',     with: 'Zero point energy machine'
    expect(page).to have_field 'address',               with: 'zero-point-energy-machine'
    expect(page).to have_field 'Your name',             with: ''
    expect(page).to have_field 'Your email address',    with: 'john@the-hutchison-effect.org', disabled: true
    expect(page).to have_field 'Password',              with: '',                              match: :prefer_exact
    expect(page).to have_field 'Password confirmation', with: ''

    fill_in 'address',               with: 'zero-point'
    fill_in 'Your name',             with: 'John Hutchison'
    fill_in 'Password',              with: 'imacharlatan',   match: :prefer_exact
    fill_in 'Password confirmation', with: 'imacharlatan'
    add_members members
    click_on 'Create'

    expect(page).to be_at_url compose_conversation_url('zero-point-energy-machine','my')

    user = threadable.users.find_by_email_address('john@the-hutchison-effect.org')
    expect(user).to be

    assert_tracked(user.user_id, 'Organization Created',
      sign_up_confirmation_token: true,
      organization_name: 'Zero point energy machine',
      email_address: 'john@the-hutchison-effect.org',
      organization_id: Organization.last.id,
    )

    drain_background_jobs!

    expect(page).to have_text 'John Hutchison'
    expect(page).to have_text 'john@the-hutchison-effect.org'
    assert_members! members
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').length ).to eq 0 # user is unconfirmed
  end

  scenario %(with an existing user's email address) do
    sign_out!
    sign_up! 'Zero point energy machine', 'bethany@ucsd.example.com'

    expect(page).to be_at_url sign_in_url(
      email_address: 'bethany@ucsd.example.com',
      r: new_organization_path(organization_name: 'Zero point energy machine'),
      notice: "You already have an account. Please sign in.",
    )
    expect(page).to have_field('Email Address', with: 'bethany@ucsd.example.com')
    within_element 'the sign in form' do
      fill_in 'Password', :with => 'password'
      click_on 'Sign in'
    end

    expect(page).to be_at_url new_organization_url(organization_name: 'Zero point energy machine')
    assert_tracked(user_id_for('bethany@ucsd.example.com'), 'New Organization Page Visited',
      sign_up_confirmation_token: false,
      organization_name: 'Zero point energy machine',
      email_address: 'bethany@ucsd.example.com',
    )
    expect(page).to have_field('Organization name', with: 'Zero point energy machine')
    expect(page).to have_field('address', with: 'zero-point-energy-machine')
    expect(page).to have_text 'Bethany Pattern'
    expect(page).to have_text 'bethany@ucsd.example.com'
  end

  def add_members members
    members.each do |name, email_address|
      all('#new_organization_members_name').last.set(name)
      all('#new_organization_members_email_address').last.tap do |input|
        input.set(email_address)
        sleep 0.2
        input.native.send_keys(:tab)
      end
    end
  end

  def assert_members! members
    within_element('the sidebar'){ find('.organization-details').click }
    within('.organization-settings'){ click_on 'Members' }
    members.each do |(name, email_address)|
      expect(page).to have_text name
      expect(page).to have_text email_address
      expect( sent_emails.with_subject("You've been invited to Zero point energy machine").sent_to(email_address) ).to be_present
    end
  end

  def user_id_for email_address
    threadable.users.find_by_email_address!(email_address).user_id
  end

end
