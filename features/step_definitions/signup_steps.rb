When /^I signup with the following information:$/ do |table|
  values = table.transpose.hashes.first
  visit new_user_registration_path
  values.each{|name, value| fill_in name, with: value }
  click_button 'Sign up'
end

def find_validation_email(email_address)
  ActionMailer::Base.deliveries.find{|email|
    email.to.include?(email_address) && \
    email.body.include?('You can confirm your account email through the link below')
  }
end

Then /^I a confirmation link should have been sent to "(.*?)"$/ do |email_address|
  find_validation_email(email_address).should be_present
end

When /^I click the validation link sent to "(.*?)"$/ do |email_address|
  email = find_validation_email(email_address)
  url = URI.extract(email.to_s, ['http']).find{|url| url.include? 'confirmation_token' }
  visit url
end

When /^I fill in the password fields with "(.*?)"(?: and "(.*?)")?$/ do |password, confirmation|
  fill_in 'user[password]', with: password
  fill_in 'user[password_confirmation]', with: confirmation || password
end
