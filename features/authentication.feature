Feature: Authentication
  As a user
  I should be able to login

Scenario: Logging in
  In order to use the site
  I'd like to keep my data associated with me
  Given the following users:
    | Name         | Email                | Password |
    | Jared Grippe | jared@jaredgrippe.me | password |
   When I am not logged in
    And I go to the home page
    And I click "Login"
    And I fill in "Email" with "jared@jaredgrippe.me"
    And I fill in "Password" with "password"
    And I click "Sign in" within the login form
   Then I should be on the home page
    And I should see "Signed in successfully."


Scenario: Failing to log in
  Given the following users:
    | Name         | Email                | Password |
    | Jared Grippe | jared@jaredgrippe.me | password |
  When I am not logged in
   And I go to the home page
   And I click "Login"
   And I fill in "Email" with "jared@jaredgrippe.me"
   And I fill in "Password" with "bullshitpassword"
   And I click "Sign in" within the login form
  Then I should see "Invalid email or password"

Scenario: Signing up through the join form
  Given I am not a member
  When I go to the home page
  And I click "Login"
  And I click "Sign up"
  And I fill in "Email" with "audrey.penven@gmail.com"
  And I fill in "Password" with "bullshitpassword"
  And I fill in "Password confirmation" with "bullshitpassword"
  Then I click "Sign up"
