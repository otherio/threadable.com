Given /^my email address is "(.*?)"$/ do |email|
  @email = email
end

Given /^there is a project called "(.*?)"$/ do |project_name|
  Api::Project.create({
    name: project_name
  })
end

Given /^there is a task "(.*?)" for the project "(.*?)"$/ do |task_name, project_name|
  Api::Project.find(project_name).tasks.create({
    project_name: project_name,
    task_name: task_name,
  })
end

When /^I am added as a doer to the task "(.*?)" for the project "(.*?)"$/ do |task_name, project_name|
  Api::Project.find(project_name).tasks.find(task_name).add_doer(@email)
end

Then /^I should get an email sent to "(.*?)"$/ do |arg1|
  pending
end

When /^I open that email$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I click the "(.*?)" link$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should be on the join page$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I enter "(.*?)" into the password field$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I press join$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be a doer of this task$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I am added as a follower to a task$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be a follower of this task$/ do
  pending # express the regexp above with the code you wish you had
end

