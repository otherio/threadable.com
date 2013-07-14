When /^I follow the unsubscribe link in an email to "(.*?)" and from the project "(.*?)"$/ do |user_name, project_name|
  project = Project.where(name: project_name).first!
  user = project.members.where(name: user_name).first!
  unsubscribe_token = UnsubscribeToken.encrypt(project.id, user.id)
  visit project_unsubscribe_path(project.slug, unsubscribe_token)
end
