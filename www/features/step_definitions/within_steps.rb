# # Then %r{^(.*?) within the email$} do |step_string|
# #   selector = selector_for(element)
# #   wait_until_expectation { find(selector) }
# #   within(selector){ step step_string }
# # end

# # encoding: UTF-8
# # within a named selector (meta step)
# # this step wraps all other steps allowing you to use any step within a particular element
# #
# # NOTE: This will NOT find things which are somehow not visible. This is by design, cause
# # you don't want to have a test think it's able to see something a user can't.
# #
# # To look inside hidden elements, use "I should find X inside Y", below.
# # TODO: Simulate actual mouseover. Fire event via page.evaluate_script()?
# #
# # Examples:
# #   When I click "Login" within the nav bar
# #   Then I should see "something" within the footer
# Then %r{^(.*?) within ([^"'].+[^:])$} do |step_string, element|
#   selector = selector_for(element)
#   wait_until_expectation { find(selector) }
#   within(selector){ step step_string }
# end

# # within a named selector (using a table) (meta step)
# # this step wraps all other steps allowing you to use any step within a particular element
# #
# # Examples:
# #   Then I should see the following within the footer:
# #    | something      |
# #    | something else |
# Then %r{^(.*?) within ([^"'].+):$} do |step_string, element, table|
#   selector = selector_for(element)
#   wait_until_expectation { find(selector) }
#   within(selector){ step step_string+':', table }
# end
