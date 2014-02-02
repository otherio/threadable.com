# require 'spec_helper'

# feature "Signup" do

#   before do
#     Rails.configuration.stub(signup_enabled: true)
#   end

#   scenario %(signing up) do
#     visit sign_up_path
#     fill_in 'Name',                  with: 'Weird Al Yankovik'
#     fill_in 'Email',                 with: 'weird.al@yankovik.com'
#     fill_in 'Password',              with: 'ilovepizza', :match => :prefer_exact
#     fill_in 'Password confirmation', with: 'ilovepizz'
#     click_button 'Sign up'
#     expect(page).to have_text "doesn't match Password"

#     fill_in 'Password',              with: 'ilovepizza', :match => :prefer_exact
#     fill_in 'Password confirmation', with: 'ilovepizza'
#     click_button 'Sign up'

#     expect(page).to have_text "You're Threadable!"
#     expect(page).to have_text "We just sent you an email with a link to confirm your email address and let you set a password for your account."

#     drain_background_jobs!
#     confirmation_email = sent_emails.to('weird.al@yankovik.com').containing('Please visit this url confirm your account').first
#     expect(confirmation_email).to be_present
#     url = confirmation_email.urls.find{|url| url.to_s =~ %r{email_addresses/confirm} }
#     expect(url).to be_present
#     visit url.to_s

#     expect_to_be_signed_in_as! "Weird Al Yankovik"
#   end

# end
