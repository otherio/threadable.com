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
  page.should have_selector(".task_metadata .doers .name", text: doer)
end

Given /^I click doer "(.*?)"$/ do |name|
  find('a.item', text: name).click
end

When /^I add a new task titled "(.*?)"$/ do |task_subject|
  within_element 'the tasks sidebar' do
    fill_in 'subject', with: task_subject
    find('.icon-plus').click
  end
end

When /^I add "(.*?)" as a doer for this task$/ do |doer_name|
  click_on 'add others'
  fill_in 'add-others-typeahead', with: doer_name
  click_on doer_name
end
