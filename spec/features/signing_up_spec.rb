require 'spec_helper'

feature "signing up" do

  let :members do
    [
      ['Sathya Sai Baba', 'sathya@saibaba.me'],
      ['Edgar Cayce', 'edgar@edgarcayce.org'],
      ['Deepak Chopra', 'deepak@chopra.me'],
    ]
  end

  scenario %(with a new email address), fixtures: false do
    visit sign_up_url
    assert_tracked(nil, 'Sign up page visited')

    fill_in 'Organization name', with: 'Zero point energy machine'
    fill_in 'Email address', with: 'john@the-hutchison-effect.org'
    click_on 'Sign up'
    expect(page).to have_text 'Thank you'
    expect(page).to have_text 'Please click the link in your email'
    assert_tracked(nil, 'Signed up',
      organization_name: 'Zero point energy machine',
      email_address: 'john@the-hutchison-effect.org',
      result: 'rendered thank you and sent email',
    )

    drain_background_jobs!
    emails = sent_emails.to('john@the-hutchison-effect.org')
    expect(emails.length).to eq 1
    email = emails.first
    expect(email.subject).to eq 'Welcome to Threadable!'

    sent_emails.clear
    visit email.link('Click here to confirm your account')[:href]

    expect(page).to have_field('Organization name', with: 'Zero point energy machine')
    expect(page).to have_field('address', with: 'zero-point-energy-machine')
    expect(page).to have_field('Your email address', with: 'john@the-hutchison-effect.org', disabled: true)

    assert_tracked(nil, 'New Organization Page Visited',
      sign_up_confirmation_token: true,
      organization_name: 'Zero point energy machine',
      email_address: 'john@the-hutchison-effect.org',
    )

    fill_in 'address', with: 'zero-point'
    fill_in 'Your name', with: 'John Hutchison'
    fill_in 'password', with: 'imacharlatan', :match => :prefer_exact
    fill_in 'password confirmation', with: 'imacharlatan', :match => :prefer_exact
    add_members members
    click_on 'Create'

    assert_tracked(user_id_for('john@the-hutchison-effect.org'), 'Organization Created',
      sign_up_confirmation_token: true,
      organization_name: 'Zero point energy machine',
      email_address: 'john@the-hutchison-effect.org',
      organization_id: Organization.last.id,
    )

    drain_background_jobs!
    expect(page).to be_at_url conversations_url('zero-point-energy-machine','my')
    expect(page).to have_text 'John Hutchison'
    expect(page).to have_text 'john@the-hutchison-effect.org'
    assert_members! members
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').length ).to eq 0 # user is unconfirmed
  end

  scenario %(with an existing user's email address) do
    visit sign_up_url
    assert_tracked(nil, 'Sign up page visited')

    fill_in 'Organization name', with: 'Zero point energy machine'
    fill_in 'Email address', with: 'bethany@ucsd.example.com'
    click_on 'Sign up'

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
      email_address: nil,
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
