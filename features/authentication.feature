Feature: Authentication
  As a user
  I should be able to login

Scenario: Logging in
  Given the following users:
    | Name         | Email                | Password |
    | Jared Grippe | jared@jaredgrippe.me | password |
   When I am not logged in
    And I go to the home page
    And I click "Login"
    And I fill in "Email" with "jared@jaredgrippe.me"
    And I fill in "Password" with "password"
    And I click "Login" within the login form
   Then I should be on the home page
    And I should see "Welcome back Jared Grippe"
