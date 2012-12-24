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
  fill_in 'Email',    :with => info['email']
  fill_in 'Password', :with => info['password']
  click_on 'Join'
end

Then /^I should be logged in as "(.*?)"$/ do |name|
  page.should have_content("#{name}")
end
