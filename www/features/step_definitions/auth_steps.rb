Given /^I am logged in as:$/ do |table|
  user = table.hashes.first
  user = Multify::User.create(user)
  step %{I login as "#{user.email}"}
end

When /^I login as "([^"]+)"$/ do |email|
  visit root_path
  fill_in 'Email', :with => email
  click_on 'Login'
end

Then /^I should be logged in as "(.*?)"$/ do |name|
  page.should have_content("Hey #{name}")
end
