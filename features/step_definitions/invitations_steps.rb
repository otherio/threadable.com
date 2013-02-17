When /^I invite "(.*?)", "(.*?)" to the "(.*?)" project$/ do |name, email, project|
  project = Project.find_by_name(project)
  visit project_path(project)

  within selector_for('the navbar') do
    click_on 'Invite'
  end

  within selector_for('the modal') do
    fill_in 'Name', with: name
    fill_in 'Email', with: email
    click_on 'Invite'
  end
end
