Given /^I am not logged in$/ do
  visit '/'
  page.should have_content('Multify')
end
