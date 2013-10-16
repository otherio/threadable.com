When /^I signup with the following information:$/ do |table|
  values = table.transpose.hashes.first
  visit sign_up_path
  values.each{|name, value| fill_in name, with: value }
  click_button 'Sign up'
end

def find_validation_email(email_address)
  sent_emails.to(email_address).containing('Please visit this url confirm your account').first
end

Then(/^"(.*?)" should have a confirmation email$/) do |email_address|
  find_validation_email(email_address).should be_present
end

When(/^I click the account confirmation link sent to "(.*?)"$/) do |email_address|
  email = find_validation_email(email_address)
  url = email.urls.find{|url| url =~ %r{users/confirm} }
  visit url
end

When /^I fill in the password fields with "(.*?)"(?: and "(.*?)")?$/ do |password, confirmation|
  fill_in 'user[password]', with: password
  fill_in 'user[password_confirmation]', with: confirmation || password
end
