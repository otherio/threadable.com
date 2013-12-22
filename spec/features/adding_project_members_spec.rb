require 'spec_helper'

feature "Adding project members" do

  before do
    sign_in_as 'alice@ucsd.covered.io'
  end

  scenario %(adding an unregistered user to a project) do
    add_member_to_project 'Frank Zappa', 'frank@zappaworld.net', 'raceteam', 'Frank, we need a theme song!'
    expect(page).to have_text "Hey! Frank Zappa <frank@zappaworld.net> was added to this project."
    sign_out!

    drain_background_jobs!

    email = sent_emails.join_notices("UCSD Electric Racing").sent_to('frank@zappaworld.net').first
    expect(email.user_setup_url).to be_present
    expect(email.content).to include 'Frank, we need a theme song!'
    expect(email.content).to_not include "You can view this project on covered.io here: #{project_url('raceteam')}"
    expect(email.content).to include "Click here to set up a password"
  end

  scenario %(adding an existing user who is not a member to a project) do
    add_member_to_project 'B.J. Hunnicutt',  'bj@sfhealth.example.com', 'raceteam', 'hey, we need some medical support'
    expect(page).to have_text "Hey! B.J. Hunnicutt <bj@sfhealth.example.com> was added to this project."
    sign_out!

    drain_background_jobs!

    email = sent_emails.join_notices("UCSD Electric Racing").sent_to('bj@sfhealth.example.com').first
    expect(email.user_setup_url).to_not be_present
    expect(email.content).to include 'hey, we need some medical support'
    expect(email.content).to include "You can view this project on covered.io here: #{project_url('raceteam')}"
    expect(email.content).to_not include "Click here to set up a password"
  end

  scenario %(adding an existing member to a project) do
    add_member_to_project 'Yan Zhu', 'yan@ucsd.covered.io', 'raceteam'
    expect(page).to have_text "Notice! That user is already a member of this project."
  end

  scenario %(being added to a project) do
    add_member_to_project 'Archimedes Vanderhimen', 'archimedes@ucsd.covered.io', 'raceteam', 'We need your sick driving skills!'
    sign_out!

    drain_background_jobs!

    email = sent_emails.join_notices("UCSD Electric Racing").sent_to('archimedes@ucsd.covered.io').first
    expect(email.user_setup_url).to be_present
    expect(email.content).to include 'We need your sick driving skills!'
    visit email.user_setup_url.to_s

    expect(current_path).to start_with setup_users_path(token:1)[0..-2]
    expect(page).to have_text "You're almost in!"


    expect(find_field('Name', :match => :prefer_exact).value).to eq 'Archimedes Vanderhimen'
    expect(find_field('Password', :match => :prefer_exact).value).to be_blank
    expect(find_field('Password confirmation', :match => :prefer_exact).value).to be_blank

    fill_in "Name", with: "Archimedes Van-Dérhimen"
    fill_in "Password", with: "password", match: :prefer_exact
    fill_in "Password confirmation", with: "password"
    click_on "Setup my account"

    expect(current_url).to eq project_conversations_url('raceteam')
    expect_to_be_signed_in_as! 'Archimedes Van-Dérhimen'

    user = covered.users.find_by_email_address('archimedes@ucsd.covered.io')
    expect(user.email_address).to be_primary
    expect(user.email_address).to be_confirmed
    expect(user.email_address.address).to eq 'archimedes@ucsd.covered.io'
    expect(user.email_addresses.count).to eq 1
  end

  def add_member_to_project name, email_address, project_slug, personal_message=nil
    visit project_path(project_slug)

    within selector_for('the navbar') do
      click_on 'Add'
    end

    within selector_for('the modal') do
      fill_in 'Name', with: name
      fill_in 'Email', with: email_address
      fill_in 'Message', with: personal_message
      click_on 'Add member'
    end
  end

end
