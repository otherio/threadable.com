require 'spec_helper'

feature "Creating an organization" do

  context "when not signed in" do
    scenario %(visiting /create prompts me to sign in) do
      sign_out!
      visit new_organization_url
      expect(page).to be_at_url sign_in_url(r: new_organization_path)
      sign_in_as_bethany!
      expect(page).to be_at_url new_organization_url
    end
  end

  context "when signed in" do
    def members
      [
        ['Sathya Sai Baba', 'sathya@saibaba.me'],
        ['Edgar Cayce', 'edgar@edgarcayce.org'],
        ['Deepak Chopra', 'deepak@chopra.me'],
      ]
    end

    before{ sign_in_as 'bethany@ucsd.example.com' }

    scenario %(I should be able to create an organization) do
      visit new_organization_url
      fill_in 'Organization name', with: 'Zero point energy machine'
      expect(page).to have_field('address', with: 'zero-point-energy-machine')
      fill_in 'address', with: 'zero-point'
      expect(page).to_not have_field('Your name')
      expect(page).to_not have_field('password')
      expect(page).to_not have_field('password confirmation')
      expect(page).to have_text 'Bethany Pattern'
      expect(page).to have_text 'bethany@ucsd.example.com'
      add_members members
      click_on 'Create'
      expect(page).to be_at_url conversations_url('zero-point-energy-machine','my')
      expect(page).to have_text 'Bethany Pattern'
      expect(page).to have_text 'bethany@ucsd.example.com'
      assert_members! members
      expect( sent_emails.sent_to('bethany@ucsd.example.com') ).to be_blank
    end

    scenario %(clicking the "This is not me" link) do
      visit new_organization_url
      click_on 'This is not me'
      expect(page).to be_at_url sign_in_url(r: new_organization_path)
      sign_in_as_bethany!
      expect(page).to be_at_url new_organization_url
    end
  end


  def sign_in_as_bethany!
    within_element 'the sign in form' do
      fill_in 'Email Address', :with => 'bethany@ucsd.example.com'
      fill_in 'Password', :with => 'password'
      click_on 'Sign in'
    end
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
    drain_background_jobs!
    within_element('the sidebar'){ find('.organization-details').click }
    within('.organization-settings'){ click_on 'Members' }
    members.each do |(name, email_address)|
      expect(page).to have_text name
      expect(page).to have_text email_address
      expect( sent_emails.with_subject("You've been added to Zero point energy machine").sent_to(email_address) ).to be_present
    end
  end

end
