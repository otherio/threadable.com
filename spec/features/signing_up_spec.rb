require 'spec_helper'

feature "signing up" do

  let :members do
    [
      ['Sathya Sai Baba', 'sathya@saibaba.me'],
      ['Edgar Cayce',     'edgar@edgarcayce.org'],
      ['Deepak Chopra',   'deepak@chopra.me'],
    ]
  end

  attr_reader :original_mixpanel_distinct_id
  def sign_up! organization_name, email_address
    sign_out! # visit root_url
    # assert_tracked(mixpanel_distinct_id, 'Homepage visited') # this is client side tracked now to avoid uptime requests padding our demoninator

    @original_mixpanel_distinct_id = mixpanel_distinct_id

    within first('.sign-up-form') do
      fill_in 'Organization name',  with: organization_name
      fill_in 'Your email address', with: email_address
      click_on 'SIGN UP'
    end

    wait_until_expectation do
      assert_tracked(mixpanel_distinct_id, 'Homepage sign up',{
        email_address:     email_address,
        organization_name: organization_name,
      })
    end
  end

  scenario %(as new user), fixtures: false do
    sign_up! 'Zero point energy machine', 'john@the-hutchison-effect.org'

    expect(page).to have_text %(We've sent you a confirmation email.)
    expect(page).to have_text %(Please click the link in your email to complete your account request.)

    assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "sign_up_confirmation", 'Zero point energy machine', 'john@the-hutchison-effect.org']
    drain_background_jobs!
    email = sent_emails.to('john@the-hutchison-effect.org').with_subject("Welcome to Threadable!").last
    expect(email).to be_present
    sent_emails.clear

    confirmation_url = email.link("CONFIRM ACCOUNT")[:href]
    token = Rails.application.routes.recognize_path(confirmation_url)[:token]
    visit confirmation_url
    expect(page).to be_at_url new_organization_url(token: token)

    assert_tracked(mixpanel_distinct_id, 'New Organization Page Visited',
      sign_up_confirmation_token: true,
      organization_name: 'Zero point energy machine',
      email_address: 'john@the-hutchison-effect.org',
    )

    expect(page).to have_field 'new_organization[organization_name]',      with: 'Zero point energy machine'
    expect(page).to have_field 'new_organization[email_address_username]', with: 'zero-point-energy-machine'
    expect(page).to have_field 'new_organization[your_name]',              with: ''
    expect(page).to have_field 'new_organization[your_email_address]',     with: 'john@the-hutchison-effect.org', disabled: true
    expect(page).to have_field 'new_organization[password]',               with: '',                              match: :prefer_exact
    expect(page).to have_field 'new_organization[password_confirmation]',  with: ''

    fill_in 'new_organization[email_address_username]', with: 'zero-point'
    fill_in 'new_organization[your_name]',              with: 'John Hutchison'
    fill_in 'new_organization[password]',               with: 'imacharlatan',   match: :prefer_exact
    fill_in 'new_organization[password_confirmation]',  with: 'imacharlatan'
    add_members members
    click_on 'Create'

    expect(page).to be_at_url compose_conversation_url('zero-point-energy-machine','my')

    organization = threadable.organizations.find_by_slug!('zero-point-energy-machine')
    expect(organization.members.count).to eq 4
    expect(organization.members.find_by_email_address('john@the-hutchison-effect.org')).to be_confirmed

    my_membership = organization.members.find_by_email_address!('john@the-hutchison-effect.org')
    expect(my_membership).to be_confirmed
    expect(my_membership.role).to eq :owner

    members.each do |name, email_address|
      member = organization.members.find_by_email_address!(email_address)
      expect( member ).to_not be_confirmed
      expect( member.role ).to eq :member
    end

    user = threadable.users.find_by_email_address!('john@the-hutchison-effect.org')
    organization = threadable.organizations.find_by_slug!('zero-point-energy-machine')

    expect(mixpanel_distinct_id).to eq user.id.to_s
    expect(threadable.tracker.aliases[user.id]).to eq original_mixpanel_distinct_id

    assert_tracked(user.id, "Sign up",
      name:                 "John Hutchison",
      email_address:        "john@the-hutchison-effect.org",
      confirm_email_address: true,
    )

    assert_tracked(user.user_id, 'Organization Created',
      sign_up_confirmation_token: true,
      organization_name:         'Zero point energy machine',
      email_address:             'john@the-hutchison-effect.org',
      organization_id:            organization.id,
    )

    drain_background_jobs!

    expect(page).to have_text 'John Hutchison'
    expect(page).to have_text 'john@the-hutchison-effect.org'
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').length ).to eq 4
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').with_subject('[Zero point energy machine] Welcome to Threadable!')   ).to be
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').with_subject('[✔︎][Zero point energy machine] Add some more members') ).to be
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').with_subject('[Zero point energy machine] Threadable Tips')          ).to be
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').with_subject('Re: [Zero point energy machine] Threadable Tips')      ).to be
    assert_members! members

    visit sign_out_url
    click_on 'SIGN IN'
    fill_in 'Email Address', with: 'john@the-hutchison-effect.org'
    fill_in 'Password',      with: 'imacharlatan'
    click_on 'Sign in'

    expect(page).to be_at_url conversations_url('zero-point-energy-machine','my')
  end



  scenario %(with an existing user's email address) do
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
    expect(page).to have_field('new_organization[organization_name]', with: 'Zero point energy machine')
    expect(page).to have_field('new_organization[email_address_username]', with: 'zero-point-energy-machine')
    expect(page).to have_text 'Bethany Pattern'
    expect(page).to have_text 'bethany@ucsd.example.com'
    expect(page).to_not have_field 'Your name'
    expect(page).to_not have_field 'Password',  match: :prefer_exact
    expect(page).to_not have_field 'Password confirmation'
    add_members members
    click_on 'Create'

    expect(page).to be_at_url compose_conversation_url('zero-point-energy-machine','my')

    bethany = threadable.users.find_by_email_address!('bethany@ucsd.example.com')
    organization = threadable.organizations.find_by_slug!('zero-point-energy-machine')

    expect(mixpanel_distinct_id).to eq bethany.user_id.to_s
    expect(threadable.tracker.aliases[bethany.user_id]).to be_nil

    assert_tracked(bethany.user_id, 'New Organization Page Visited',
      sign_up_confirmation_token: false,
      organization_name:          'Zero point energy machine',
      email_address:              'bethany@ucsd.example.com',
    )

    assert_not_tracked(bethany.user_id, "Sign up")

    assert_tracked(bethany.user_id, 'Organization Created',
      sign_up_confirmation_token: true,
      organization_name:         'Zero point energy machine',
      email_address:             'bethany@ucsd.example.com',
      organization_id:            organization.id,
    )

    drain_background_jobs!

    expect(page).to have_text 'Bethany Pattern'
    expect(page).to have_text 'bethany@ucsd.example.com'
    expect( sent_emails.sent_to('bethany@ucsd.example.com').length ).to eq 4
    expect( sent_emails.sent_to('bethany@ucsd.example.com').with_subject('[Zero point energy machine] Welcome to Threadable!')   ).to be
    expect( sent_emails.sent_to('bethany@ucsd.example.com').with_subject('[✔︎][Zero point energy machine] Add some more members') ).to be
    expect( sent_emails.sent_to('bethany@ucsd.example.com').with_subject('[Zero point energy machine] Threadable Tips')          ).to be
    expect( sent_emails.sent_to('bethany@ucsd.example.com').with_subject('Re: [Zero point energy machine] Threadable Tips')      ).to be
    assert_members! members

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
    within('.organization-controls'){ click_on 'Members' }
    members.each do |(name, email_address)|
      expect(page).to have_text name
      expect(page).to have_text email_address
      expect( sent_emails.sent_to(email_address).length ).to eq 1
      expect( sent_emails.sent_to(email_address).with_subject("You've been invited to Zero point energy machine") ).to be_present
    end
  end

  def user_id_for email_address
    threadable.users.find_by_email_address!(email_address).user_id
  end

end
