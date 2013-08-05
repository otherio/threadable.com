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

When /^I click [on]*"(.*?)"$/ do |name|
  click_on name
end

When /^I click selector "(.*)"$/ do |selector|
  page.find(selector).click
end

When /^I click the "(.*?)" button$/ do |name|
  click_button name
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
  fill_in field, with: value, :match => :prefer_exact
end

When /^I scroll to the bottom of the page$/ do
  page.execute_script <<-JS
    window.scrollBy(0,10000);
    var conversation_messages = $('.conversations_layout > .right')[0];
    if (conversation_messages) conversation_messages.scrollTop = 9999;
  JS
end

Then /^I should see "(.*?)"$/ do |content|
  page.should have_content content
end

Then /^I should not see "(.*?)"$/ do |content|
  page.should_not have_content content
end

When /^I debug$/ do
  binding.pry
end

Given /^this scenario is pending(?: because (.+))?$/ do |reason|
  pending reason
end


When /^I reload the page$/ do
  visit page.current_path
end


Then(/^the "(.*?)" field should be filled in with "(.*?)"$/) do |field, value|
  expect(find_field(field, :match => :prefer_exact).value).to eq value
end

Then(/^the "(.*?)" field should be blank$/) do |field|
  expect(find_field(field, :match => :prefer_exact).value).to be_blank
end
