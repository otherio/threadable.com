Then /^I should be able to edit the "(.*?)" project$/ do |project_name|
  visit path_to('the home page')
  within find('table.projects tr', text: project_name) do
    find('.actions .dropdown-toggle').click
    click_on 'Edit'
  end
  fill_in "Name", with: 'UCSD Steam Powered Racing'
  fill_in "Short name", with: 'UCSD Steam'
  fill_in "Description", with: 'Steam all the things!'
  click_on 'Update'
  page.should have_content('Notice! UCSD Steam Powered Racing was successfully updated.')

  within find('table.projects tr', text: "UCSD Steam Powered Racing") do
    find('.actions .dropdown-toggle').click
    click_on 'Edit'
  end

  find_field('Name').value.should == 'UCSD Steam Powered Racing'
  find_field('Short name').value.should == 'UCSD Steam'
  find_field('Description').value.should == 'Steam all the things!'
end

Then /^I should be able to leave the "(.*?)" project$/ do |project_name|
  visit path_to('the home page')
  within find('table.projects tr', text: project_name) do
    find('.actions .dropdown-toggle').click
    click_on 'Leave'
  end

  accept_prompt!

  visit path_to('the home page')
  page.should_not have_content project_name
end
