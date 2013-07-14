Given /^I am not logged in$/ do
  visit new_user_session_path
  page.should have_content('Covered')
end

Given /^I am "(.*?)"$/ do |name|
  @user = User.where(name: name).first!
  login_as(@user)
end

Then /^I should be logged in as "(.*?)"$/ do |name|
  find('.page_navigation .current_user a').should have_content name
end
