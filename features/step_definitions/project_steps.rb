Then /^I should be able to edit the "(.*?)" project$/ do |project_name|
  visit path_to('the home page')
  within find(%{table.projects tr:contains("#{project_name}")}) do
    find('.actions .dropdown-toggle').click
    click_on 'Edit'
  end
  fill_in "Name", with: 'UCSD Steam Powered Racing'
  fill_in "Slug", with: 'ucsd-steam-powered-racing'
  fill_in "Subject tag", with: 'ucsd-steam'
  fill_in "Description", with: 'Steam all the things!'
  click_on 'Save'
  page.should have_content('Notice! UCSD Steam Powered Racing was successfully updated.')

  within find(%{table.projects tr:contains("UCSD Steam Powered Racing")}) do
    find('.actions .dropdown-toggle').click
    click_on 'Edit'
  end

  find_field('Name').value.should == 'UCSD Steam Powered Racing'
  find_field('Slug').value.should == 'ucsd-steam-powered-racing'
  find_field('Subject tag').value.should == 'ucsd-steam'
  find_field('Description').value.should == 'Steam all the things!'
end

Then /^I should be able to leave the "(.*?)" project$/ do |project_name|
  visit path_to('the home page')
  within find(%{table.projects tr:contains("#{project_name}")}) do
    find('.actions .dropdown-toggle').click
    click_on 'Leave'
  end
  alert = page.driver.browser.switch_to.alert
  alert.accept

  visit path_to('the home page')
  page.should_not have_content project_name
end
