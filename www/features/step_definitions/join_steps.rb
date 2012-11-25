Given /^the following users:$/ do |table|
  table.hashes.each do |user|
    Multify::User.create(user)
  end
end

Given /^the following projects:$/ do |table|
  table.hashes.each do |project|
    Multify::Project.create(project)
  end
end

Given /^the following tasks:$/ do |table|
  table.hashes.each do |task|
    project = Multify::Project.find(name: task.delete('project')).first
    project.tasks.create(task)
  end
end



When /^I go to (.*)$/ do |page_name|
  visit page_name_to_path(page_name)
end

Then /^I should be on (.*)$/ do |page_name|
  URI.parse(page.current_url).path.should == page_name_to_path(page_name)
end

When /^I add "(.*?)" as a doer to the "(.*?)" task of the "(.*?)" project$/ do |email, task_slug, project_slug|
  visit project_task_path(project_slug, task_slug)
  click_on "Add Doer"
end

When /^I join with the following information:$/ do |table|
  info = table.hashes.first
  visit join_path
  fill_in 'Name',     :with => info['name']
  fill_in 'Email',    :with => info['email']
  fill_in 'Password', :with => info['password']
  click_on 'Join'
end

When /^I log out$/ do
  click_on 'Logout'
end

When /^I log in as "(.*?)" with the password "(.*?)"$/ do |email, password|
  visit root_path
  fill_in 'Email',    :with => email
  fill_in 'Password', :with => password
  click_on 'Login'
end

# When /^I click "(.*?)"$/ do |arg|
#   wait_until(20){ false } rescue nil
#   debugger;1
#   # click_on(arg)
# end


# Given /^my email address is "(.*?)"$/ do |email|
#   @email_address = email
# end

# Given /^there is a project called "(.*?)"$/ do |project_name|
#   Project.create!(name: project_name)
# end

# Given /^there is a task "(.*?)" for the project "(.*?)"$/ do |task_name, project_name|
#   Project.find_by_name(project_name).tasks.create!({
#     name: task_name,
#   })
# end

# When /^I am added as a doer to the task "(.*?)" for the project "(.*?)"$/ do |task_name, project_name|
#   user = User.find_by_email(@email_address)
#   Project.find_by_name(project_name).tasks.find_by_name(task_name).doers.add(user)
# end

# When /^I am added as a follower to the task "(.*?)" for the project "(.*?)"$/ do |task_name, project_name|
#   user = User.find_by_email(@email_address)
#   Project.find_by_name(project_name).tasks.find_by_name(task_name).followers.add(user)
# end

# When /^I open that email$/ do
#   Test::Api::Emails.emails.length.should == 1
#   @email = Test::Api::Emails.emails.last
# end

# Then /^I should get an email say I was added as a doer to the task "(.*?)" for the project "(.*?)"$/ do |arg1, arg2|
#   Test::Api::Emails.emails.length.should == 1
#   email = Test::Api::Emails.emails.last
#   email.to.should == @email_address
#   email.body.should include 'you are totally a doer bro'
# end

# Then /^I should get an email say I was added as a follower to the task "(.*?)" for the project "(.*?)"$/ do |arg1, arg2|
#   Test::Api::Emails.emails.length.should == 1
#   email = Test::Api::Emails.emails.last
#   email.to.should == @email_address
#   email.body.should include 'you are totally a follower yo!'
# end

# Then /^I should see "(.*?)" within the email$/ do |content|
#   @email.body.should include content
# end

# When /^I click the "(.*?)" link within the email$/ do |link_content|
#   # TODO html arse the email body
#   # follow link
#   doc = Nokogiri.XML(@email.body)
#   link = doc.css('a').find{|link| link.text.include? link_content }
#   link.should_not be_nil
#   link[:href].should be_present
#   visit link[:href]
# end

# Then /^I should be on the join page$/ do
#   pending # express the regexp above with the code you wish you had
# end

# When /^I enter "(.*?)" into the password field$/ do |arg1|
#   pending # express the regexp above with the code you wish you had
# end

# When /^I press join$/ do
#   pending # express the regexp above with the code you wish you had
# end

# Then /^I should be a doer of this task$/ do
#   pending # express the regexp above with the code you wish you had
# end

# Then /^I should be a follower of this task$/ do
#   pending # express the regexp above with the code you wish you had
# end

