Given /^I am not a member$/ do
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

Then /^I should be on the users page for "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should be logged in as "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I create a project called "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I create a task called "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I comment on that task "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I add "(.*?)" as a doer to that task$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^an email should be sent to "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^I am "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^I open my email$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see an email that says I have been added as a doer to the task "(.*?)" for the project "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I click "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should be on the claim your account page$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I press "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should be on the task page for "(.*?)" for the project "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^I comment on that task "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^an email should be sent to "(.*?)" with the comment "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^I add "(.*?)" as a doer to this task$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I check "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^an email should be sent to "(.*?)" saying the task "(.*?)" for the project "(.*?)" is complete$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^I log out$/ do
  pending # express the regexp above with the code you wish you had
end
