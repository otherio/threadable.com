When /^I follow the unsubscribe link in an email to "(.*?)" and from the project "(.*?)"$/ do |user_name, project_name|
  project = Covered::Project.where(name: project_name).first!
  user = Covered::User.where(name: user_name).first!
  project_membership = project.memberships.where(user: user).first!
  project_unsubscribe_token = ProjectUnsubscribeToken.encrypt(project_membership.id)
  visit project_unsubscribe_path(project.slug, project_unsubscribe_token)
end
