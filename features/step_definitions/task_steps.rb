Given /^I am on the task "(.*?)"$/ do |task|
  project = @user.projects.first
  visit "/#{project.slug}/conversations/#{task.gsub(/\s/, '-')}"
end

Then /^I should see "(.*?)" as a doer of the task$/ do |doer|
  page.should have_selector(".task_metadata .doers .name", text: doer)
end

Then /^I should not see "(.*?)" as a doer of the task$/ do |doer|
  page.should_not have_selector(".task_metadata .doers .name", text: doer)
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

When /^I (add|remove) "(.*?)" as a doer for this task$/ do |_, doer_name|
  click_on 'add/remove others'
  within '.add-remove-doers .popover' do
    fill_in 'doers-typeahead', with: doer_name
    within('.user-list'){ click_on doer_name }
  end
end
