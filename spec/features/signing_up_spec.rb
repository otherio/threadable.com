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
    fill_in 'Email address', with: 'john@the-hutchison-effect.org'
    click_on 'Sign up'
    expect(page).to have_text 'Thank you'
    expect(page).to have_text 'Please click the link in your email'

    drain_background_jobs!
    emails = sent_emails.to('john@the-hutchison-effect.org')
    expect(emails.length).to eq 1
    email = emails.first
    expect(email.subject).to eq 'Welcome to Threadable!'

    sent_emails.clear
    visit email.link('Click here to confirm your account')[:href]

    fill_in 'Organization name', with: 'Zero point energy machine'
    expect(page).to have_field('address', with: 'zero-point-energy-machine')
    fill_in 'address', with: 'zero-point'

    fill_in 'address', with: 'zero-point'
    fill_in 'Your name', with: 'John Hutchison'
    fill_in 'password', with: 'imacharlatan', :match => :prefer_exact
    fill_in 'password confirmation', with: 'imacharlatan', :match => :prefer_exact
    add_members members
    click_on 'Create'

    drain_background_jobs!
    expect(page).to be_at_url conversations_url('zero-point-energy-machine','my')
    expect(page).to have_text 'John Hutchison'
    expect(page).to have_text 'john@the-hutchison-effect.org'
    assert_members! members
    expect( sent_emails.sent_to('john@the-hutchison-effect.org').length ).to eq 2 # demo content gets sent, currently
  end

  scenario %(with an existing user's email address) do
    visit sign_up_url
    fill_in 'Email address', with: 'bethany@ucsd.example.com'
    click_on 'Sign up'
    expect(page).to be_at_url sign_in_url(email_address: 'bethany@ucsd.example.com')
    expect(page).to have_field('Email Address', with: 'bethany@ucsd.example.com')
    within_element 'the sign in form' do
      fill_in 'Password', :with => 'password'
      click_on 'Sign in'
    end
    expect(page).to be_at_url conversations_url('raceteam', 'my')
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
      expect( sent_emails.with_subject("You've been added to Zero point energy machine").sent_to(email_address) ).to be_present
    end
  end

end
