require 'spec_helper'

feature "Organizations" do

  before do
    sign_in_as 'tom@ucsd.example.com'
  end

  scenario %(editing a organization) do
    within find('table.organizations tr', text: 'UCSD Electric Racing') do
      find('.actions .dropdown-toggle').click
      click_on 'Edit'
    end
    fill_in "Name", with: 'UCSD Steam Powered Racing'
    fill_in "Short name", with: 'UCSD Steam'
    fill_in "Description", with: 'Steam all the things!'
    click_on 'Update'
    page.should have_content('Notice! UCSD Steam Powered Racing was successfully updated.')

    within find('table.organizations tr', text: "UCSD Steam Powered Racing") do
      find('.actions .dropdown-toggle').click
      click_on 'Edit'
    end

    find_field('Name').value.should == 'UCSD Steam Powered Racing'
    find_field('Short name').value.should == 'UCSD Steam'
    find_field('Description').value.should == 'Steam all the things!'
  end

  scenario %(leaving a organization) do
    within find('table.organizations tr', text: 'UCSD Electric Racing') do
      find('.actions .dropdown-toggle').click
      click_on 'Leave'
    end

    accept_prompt!

    visit path_to('the home page')
    page.should_not have_content 'UCSD Electric Racing'
  end

end
