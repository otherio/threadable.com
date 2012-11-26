Given /^I am logged in as:$/ do |table|
  user = table.hashes.first
  user = Multify::User.create(user)
  step %{I log in as "#{user.email}" with the password "#{user.password}"}
end

When /^I log in as "([^"]+)" with the password "([^"]+)"$/ do |email, password|
  visit root_path
  fill_in 'Email',    :with => email
  fill_in 'Password', :with => password
  click_on 'Login'
end

Then /^I should be logged in as "(.*?)"$/ do |name|
  page.should have_content("Hey #{name}")
end
