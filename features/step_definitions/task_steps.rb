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
  page.should have_content(doer)  #probably this will have to inspect the html for the tooltip or alt txt
end
