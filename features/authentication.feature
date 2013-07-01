Feature: Authentication
  As a user
  I should be able to login

Scenario: Logging in
  In order to use the site
  I'd like to keep my data associated with me
  Given I am not logged in
    And I go to the sign in page
    And I fill in "Email" with "alice@ucsd.coveredapp.com"
    And I fill in "user_password" with "password"
    And I click the "Sign in" button
   Then I should be on the home page
    And I should be logged in as "Alice Neilson"

Scenario: Logging in with both of my emails
  As a user with multiple email addresses
  I should be able to login with any of them.
  Given I am not logged in
    And I go to the sign in page
    And I click "Login"
    And I fill in "Email" with "ray@gmail.coveredapp.com"
    And I fill in "user_password" with "password"
    And I click the "Sign in" button
   Then I should be on the home page
    And I should be logged in as "Ray Arvidson"

Scenario: Failing to log in
  Given I am not logged in
    And I go to the sign in page
    And I click "Login"
    And I fill in "Email" with "alice@ucsd.coveredapp.com"
    And I fill in "user_password" with "bullshitpassword"
    And I click the "Sign in" button
   Then I should see "Invalid email or password"

Scenario: Forgot password form works for existing users
  If I have an account
  and I forget my password
  I should be able to reset it
  Given this scenario is pending because of a lame devise bug
   When I am not logged in
    And I go to the sign in page
    And I click "Login"
    And I click "Forgot your password"
    And I fill in "Email" with "alice@ucsd.coveredapp.com"
    And I click "Send me reset password instructions"
   Then I should see "You will receive an email with instructions about how to reset your password"

Scenario: Forgot password form should notify the user if an account doesn't exist with the specified email address
  If I do not have an account
  and I try to use the forgot password form
  I should see an error
  Given I am not a member
   When I go to the sign in page
    And I click "Login"
    And I click "Forgot your password"
    And I fill in "Email" with "fakeuser@gmail.com"
    And I click "Send me reset password instructions"
   Then I should see "Notice! You will receive an email with instructions about how to reset your password in a few minutes."
