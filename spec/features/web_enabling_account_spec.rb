# require "spec_helper"

# feature "web enabling account" do

#   let(:user){ covered.users.find_by_email_address! 'yan@ucsd.example.com' }

#   scenario "Users who are not web enabled should be able web enable their account" do
#     visit '/'
#     click_link 'Sign in'
#     click_link 'Forgot password'
#     fill_in 'Email', with: user.email_address
#     click_button 'Recover'
#     expect(page).to have_text "Thanks! We've emailed you a password reset link. Please check your email."

#     run_background_jobs!

#     email = sent_emails.to(user.email_address).with_subject("Reset your password!").first
#     expect(email).to be_present

#     link = email.link("Click here to reset your password")
#     expect(link).to be_present

#     visit link[:href]

#     fill_in 'user[password]', with: 'p@$$w0rd'
#     fill_in 'user[password_confirmation]', with: 'sdfddsfs'
#     click_button 'Update'
#     expect(page).to have_text "doesn't match Password"

#     fill_in 'user[password]', with: 'p@$$w0rd'
#     fill_in 'user[password_confirmation]', with: 'p@$$w0rd'
#     click_button 'Update'
#     expect(page).to have_text "Notice! Your password has been updated"

#     click_link user.name
#     click_link 'Sign out'
#     click_link 'Sign in'
#     fill_in 'Email', with: user.email_address
#     fill_in 'Password', with: 'p@$$w0rd'
#     click_button 'Sign in'

#     find('.page_navigation .current_user a').should have_text user.name
#   end

# end
