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
  pending # express the regexp above with the code you wish you had
end

Given /^I am not logged in$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I login with the following information:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

Given /^I am logged in$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I logout$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be logged out$/ do
  pending # express the regexp above with the code you wish you had
end
