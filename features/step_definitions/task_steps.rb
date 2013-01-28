# # # TODO: make this log in a persona from a fixture
# # user = FactoryGirl.create(:user, password: 'password')

# Given /^that I am logged in$/ do
#   visit '/'

#   page.should have_content('multify')

#   if page.has_content?("Sign in")
#     click_link 'Sign in'
#     fill_in 'Email',    :with => user.email
#     fill_in 'Password', :with => 'password'
#     click_button 'Sign in'
#   end
# end

# When /^I create a project called "(.*?)"$/ do |project_name|
#   fill_in 'New Project', :with => project_name
#   find('form input[placeholder="New Project"]').native.send_keys(:return)
# end

# Then /^the project called "(.*?)" should be created$/ do |project_name|
#   page.should have_content(project_name)
# end

# Given /^I am on the page for the project "(.*?)"$/ do |project_name|
#   click_on project_name
# end

# Given /^I create a task called "(.*?)"$/ do |task_name|
#   fill_in "New Task", :with => task_name
#   find('form input[placeholder="New Task"]').native.send_keys(:return)
# end

# Then /^a task called "(.*?)" should be created in the project "(.*?)"$/ do |project_name, task_name|
#   page.should have_content(task_name)
# end

# Given /^I click completed on the task "(.*?)"$/ do |task_name|
#   find(:xpath, "//*[contains(text(),'" + task_name + "')]/..").find(:css, 'td.task-status').click
# end

# Then /^the task "(.*?)" should be marked as complete$/ do |task_name|
#   find(:css, '.done').text.should eq(task_name)
# end

# Given /^I click the "(.*?)" button$/ do |button|
#   click_on(button)
# end

# Then /^the task "(.*?)" should no longer be visible$/ do |task|
#   page.should_not have_content(task)
# end

# Then /^the task "(.*?)" should be visible$/ do |task|
#   page.should have_content(task)
# end
