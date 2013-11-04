When(/^I add "(.*?)", "(.*?)" to the "(.*?)" project$/) do |name, email, project|
  project = Covered::Project.where(name: project).first!
  visit project_path(project)

  within selector_for('the navbar') do
    click_on 'Add'
  end

  within selector_for('the modal') do
    fill_in 'Name', with: name
    fill_in 'Email', with: email
    click_on 'Add member'
  end
end

When(/^"(.*?)" adds "(.*?)" "(.*?)" to the "(.*?)" project:$/) do |from, name, to_address, project_name, message|
  actor = Covered::User.where(name: from).first!
  covered = Covered.new(self.covered.env.merge(current_user: actor))
  covered.add_member_to_project(
    project: Covered::Project.where(name: project_name).first!,
    member: {
      email: to_address,
      name: name,
    },
    message: message,
  )
  drain_background_jobs!
end

Then(/^"(.*?)" should have recieved a join notice email for the "(.*?)" project$/) do |to_address, project_name|
  expect(sent_emails.join_notices(project_name).sent_to(to_address).first).to be_present
end

When(/^I click the project link in the join notice email sent to "(.*?)" for the "(.*?)" project$/) do |to_address, project_name|
  email = sent_emails.join_notices(project_name).sent_to(to_address).first
  expect(email.user_setup_url).to be_present
  visit email.user_setup_url.to_s
end
