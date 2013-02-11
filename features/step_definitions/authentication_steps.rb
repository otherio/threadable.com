Given /^I am not logged in$/ do
  visit '/'
  page.should have_content('Multify')
end

Given /^I am "(.*?)"$/ do |name|
  @user = User.find_by_name(name)
  login_as(@user)
end
