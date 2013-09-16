When(/^I invite "(.*?)", "(.*?)" to the "(.*?)" project$/) do |name, email, project|
  project = Project.where(name: project).first!
  visit project_path(project)

  within selector_for('the navbar') do
    click_on 'Add'
  end

  within selector_for('the modal') do
    fill_in 'Name', with: name
    fill_in 'Email', with: email
    fill_in 'Message', with: "hi i like you"
    click_on 'Add member'
  end

  page.should_not have_selector('.invite_modal')
end

Then(/^"(.*?)" should have received an email containing the text: "(.*?)"$/) do |to_address, email_body|
  ActionMailer::Base.deliveries.last.should be
  email = ActionMailer::Base.deliveries.last
  email.to.should include to_address
  email.body.should include email_body
end
