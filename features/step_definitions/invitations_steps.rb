When /^I invite "(.*?)", "(.*?)" to the "(.*?)" project$/ do |name, email, project|
  project = Project.where(name: project).first!
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


Given(/^"(.*?)" sent an invite to "(.*?)" "(.*?)" for the "(.*?)" project:$/) do |from, name, to_address, project_name, message|
  AddMemberToProject.call(
    actor: User.where(name: from).first!,
    project: Project.where(name: project_name).first!,
    member: {
      email: to_address,
      name: name,
    },
    message: message,
  )
end

Then(/^"(.*?)" should have recieved an email like this:$/) do |to_address, email_body|
  emails = ActionMailer::Base.deliveries.find_all{|email| email.to.include? to_address }
  bodies = emails.map{|email| email.body.to_s }
  bodies.should include(email_body)
end

When(/^I click the link in the invite email sent to "(.*?)" for the "(.*?)" project$/) do |to_address, project_name|
  email = ActionMailer::Base.deliveries.find do |email|
    email.to.include?(to_address) && email.subject == "You're invited to #{project_name}"
  end
  expect(email).to be_present
  link = URI.extract(email.body.to_s).find{|link| link =~ %r(/subscribe/) }
  expect(link).to be_present
  visit link
end
