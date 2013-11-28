require 'spec_helper'

feature "Adding project members" do

  scenario %(adding an unregistered user to a project) do
    sign_in_as 'alice@ucsd.covered.io'
    add_member_to_project 'Frank Zappa', 'frank@zappaworld.net', 'raceteam'
    expect(page).to have_text "Hey! Frank Zappa <frank@zappaworld.net> was added to this project."
  end

  scenario %(adding an existing user to a project) do
    sign_in_as 'alice@ucsd.covered.io'
    add_member_to_project 'Yan Zhu', 'yan@ucsd.covered.io', 'raceteam'
    expect(page).to have_text "Notice! That user is already a member of this project."
  end

  scenario %(being added to a project) do
    i_am 'alice@ucsd.covered.io'
    project = current_user.projects.find_by_slug! 'raceteam'
    project.members.add(
      name: 'Archimedes Vanderhimen',
      email_address: 'archimedes@ucsd.covered.io',
      personal_message: 'We need your sick driving skills!'
    )
    drain_background_jobs!

    email = sent_emails.join_notices("UCSD Electric Racing").sent_to('archimedes@ucsd.covered.io').first
    email = sent_emails.join_notices("UCSD Electric Racing").sent_to('archimedes@ucsd.covered.io').first
    expect(email.user_setup_url).to be_present
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
  end

  def add_member_to_project name, email_address, project_slug
    visit project_path(project_slug)

    within selector_for('the navbar') do
      click_on 'Add'
    end

    within selector_for('the modal') do
      fill_in 'Name', with: name
      fill_in 'Email', with: email_address
      click_on 'Add member'
    end
  end

end
