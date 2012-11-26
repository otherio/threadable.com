require 'spec_helper'

describe "integration" do

  it "should work" do

    name = 'Sparkle McPonytron'
    email = "#{Time.now.to_i}@#{rand(10000)}.com"

    visit '/join'
    fill_in 'Name', :with => name
    fill_in 'Email', :with => email
    fill_in 'Password', :with => 'threeponylimit'
    click_on 'Join'

    page.should have_content("Hi #{name}, Welcome to Multify")

    click_on 'New Project'

    project_name = "Round up #{Time.now.to_i} Ponies"
    fill_in 'Name', :with => project_name
    click_on 'Save'

    page.should have_content("Project #{project_name} was successfully created.")

    click_on 'Tasks'
    click_on 'New Task'

    task_name = "Hire #{Time.now.to_i / 2} amount of Pony-finding dogs"
    fill_in 'Name', :with => task_name
    click_on 'Save'

    page.should have_content("Name: #{task_name}")

  end

end
