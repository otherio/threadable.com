# within a named selector (meta step)
# this step wraps all other steps allowing you to use any step within a particular element
#
# NOTE: This will NOT find things which are somehow not visible. This is by design, cause
# you don't want to have a test think it's able to see something a user can't.
#
# To look inside hidden elements, use "I should find X inside Y", below.
# TODO: Simulate actual mouseover. Fire event via page.evaluate_script()?
#
# Examples:
#   When I click "Login" within the nav bar
#   Then I should see "something" within the footer
Then %r{^(.*?) within ([^"'].+[^:])$} do |step_string, element|
  within(selector_for(element)){ step step_string }
end

# within a named selector (using a table) (meta step)
# this step wraps all other steps allowing you to use any step within a particular element
#
# Examples:
#   Then I should see the following within the footer:
#    | something      |
#    | something else |
Then %r{^(.*?) within ([^"'].+):$} do |step_string, element, table|
  selector = selector_for(element)
  within(selector){ step step_string+':', table }
end


When /^I go to (.+)$/ do |name|
  visit path_to(name)
end

Then /^I should be on (.+)$/ do |name|
  page.current_path.should == path_to(name)
end

When /^I click "(.*?)"$/ do |name|
  click_on name
end


When /^I click the "(.*?)" button$/ do |name|
  click_button name
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
  fill_in field, with: value
end

Then /^I should see "(.*?)"$/ do |content|
  page.should have_content content
end

Then /^I should not see "(.*?)"$/ do |content|
  page.should_not have_content content
end

When /^I debug$/ do
  require 'debugger'
  debugger;1
end

Given /^this scenario is pending(?: because (.+))?$/ do |reason|
  pending reason
end
