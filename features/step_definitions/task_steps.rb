Given /^I am on the task "(.*?)"$/ do |task|
  project = @user.projects.first
  visit "/#{project.slug}/conversations/#{task.gsub(/\s/, '-')}"
end

Given /^I add "(.*?)" as a doer$/ do |doer|
  pending
  page.find(".add-others").click
  fill_in "add-others-typeahead", :with => doer
end

Then /^I should see "(.*?)" as a doer of the task$/ do |doer|
  page.find(".doers img[alt='#{doer}']").should be
end

Given /^I click doer "(.*?)"$/ do |name|
  find('a.item', text: name).click
end

