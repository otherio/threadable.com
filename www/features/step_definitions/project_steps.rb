When /^I create the following projects?:$/ do |table|
  table.hashes.each do |project|
    visit new_project_path
    fill_in 'Name', :with => project['name']
    fill_in 'Slug', :with => project['slug']
    fill_in 'Description', :with => project['description']
    click_on 'Save'
    URI.parse(page.current_url).path.should == project_path(project['slug'])
  end
end
