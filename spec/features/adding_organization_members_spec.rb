# require 'spec_helper'

# feature "Adding organization members" do

#   before do
#     sign_in_as 'alice@ucsd.example.com'
#   end

#   scenario %(adding an unregistered user to a organization) do
#     add_member_to_organization 'Frank Zappa', 'frank@zappaworld.net', 'raceteam', 'Frank, we need a theme song!'
#     expect(page).to have_text "Hey! Frank Zappa <frank@zappaworld.net> was added to this organization."
#     sign_out!

#     drain_background_jobs!

#     email = sent_emails.join_notices("UCSD Electric Racing").sent_to('frank@zappaworld.net').first
#     expect(email.user_setup_url).to be_present
#     expect(email.content).to include 'Frank, we need a theme song!'
#     expect(email.content).to_not include "You can view this organization on covered.io here: #{organization_url('raceteam')}"
#     expect(email.content).to include "Click here to set up a password"
#   end

#   scenario %(adding an existing user who is not a member to a organization) do
#     add_member_to_organization 'B.J. Hunnicutt',  'bj@sfhealth.example.com', 'raceteam', 'hey, we need some medical support'
#     expect(page).to have_text "Hey! B.J. Hunnicutt <bj@sfhealth.example.com> was added to this organization."
#     sign_out!

#     drain_background_jobs!

#     email = sent_emails.join_notices("UCSD Electric Racing").sent_to('bj@sfhealth.example.com').first
#     expect(email.user_setup_url).to_not be_present
#     expect(email.content).to include 'hey, we need some medical support'
#     expect(email.content).to include "You can view this organization on covered.io here: #{organization_url('raceteam')}"
#     expect(email.content).to_not include "Click here to set up a password"
#   end

#   scenario %(adding an existing member to a organization) do
#     add_member_to_organization 'Yan Zhu', 'yan@ucsd.example.com', 'raceteam'
#     expect(page).to have_text "Notice! That user is already a member of this organization."
#   end

#   scenario %(being added to a organization) do
#     add_member_to_organization 'Archimedes Vanderhimen', 'archimedes@ucsd.example.com', 'raceteam', 'We need your sick driving skills!'
#     sign_out!

#     drain_background_jobs!

#     email = sent_emails.join_notices("UCSD Electric Racing").sent_to('archimedes@ucsd.example.com').first
#     expect(email.user_setup_url).to be_present
#     expect(email.content).to include 'We need your sick driving skills!'
#     visit email.user_setup_url.to_s

#     expect(current_path).to start_with setup_users_path(token:1)[0..-2]
#     expect(page).to have_text "You're almost in!"


#     expect(find_field('Name', :match => :prefer_exact).value).to eq 'Archimedes Vanderhimen'
#     expect(find_field('Password', :match => :prefer_exact).value).to be_blank
#     expect(find_field('Password confirmation', :match => :prefer_exact).value).to be_blank

#     fill_in "Name", with: "Archimedes Van-Dérhimen"
#     fill_in "Password", with: "password", match: :prefer_exact
#     fill_in "Password confirmation", with: "password"
#     click_on "Setup my account"

#     expect(current_url).to eq organization_conversations_url('raceteam')
#     expect_to_be_signed_in_as! 'Archimedes Van-Dérhimen'

#     user = covered.users.find_by_email_address('archimedes@ucsd.example.com')
#     expect(user.email_address).to be_primary
#     expect(user.email_address).to be_confirmed
#     expect(user.email_address.address).to eq 'archimedes@ucsd.example.com'
#     expect(user.email_addresses.count).to eq 1
#   end

#   def add_member_to_organization name, email_address, organization_slug, personal_message=nil
#     visit organization_path(organization_slug)

#     within selector_for('the navbar') do
#       click_on 'Add'
#     end

#     within selector_for('the modal') do
#       fill_in 'Name', with: name
#       fill_in 'Email', with: email_address
#       fill_in 'Message', with: personal_message
#       click_on 'Add member'
#     end
#   end

# end
