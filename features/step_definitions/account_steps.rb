require 'faker'

# we need unique emails, so make sure this changes every time.
email = Faker::Internet.email

Given /^I am not a member$/ do
  #clear cookies and shit
end

When /^I go to multify\.com$/ do
  visit '/'
end

When /^I join with the following information:$/ do |table|
  info = table.hashes.first

  visit '/'
  click_on 'Sign Up'
  fill_in 'Name',     :with => info['name']
  fill_in 'Email',    :with => email
  fill_in 'Password', :with => info['password']
  click_on 'Join'
end

Then /^I should be logged in as "(.*?)"$/ do |name|
  page.should have_content("#{name}")
end

Given /^that I am "(.*?)"$/ do |arg1|
  # TODO: clear cookies or whatever
end

When /^I login with the following information:$/ do |table|
  info = table.hashes.first

  visit '/'
  click_link 'Sign in'
  fill_in 'Email',    :with => email
  fill_in 'Password', :with => info['password']
  click_button 'Sign in'
end

Given /^that I am logged in as "(.*?)" with password "(.*?)"$/ do |fake_email, password|
  # TODO: replace this with something that makes the api call directly
  # to make the tests faster
  visit '/'
  if page.has_content?("Sign in")
    click_link 'Sign in'
    fill_in 'Email',    :with => email
    fill_in 'Password', :with => password
    click_button 'Sign in'
  end
end

When /^I logout$/ do
  click_on 'account-menu'
  click_on 'Sign out'
end

Then /^I should be logged out$/ do
  page.should have_content("Sign in")
end
