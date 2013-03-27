When /^I follow the unsubscribe link in an email to "(.*?)" and from the project "(.*?)"$/ do |user_name, project_name|
  project = Project.find_by_name(project_name)
  user = project.members.find_by_name(user_name)
  unsubscribe_token = UnsubscribeToken.encrypt(project.id, user.id)
  visit project_unsubscribe_path(project.slug, unsubscribe_token)
end
