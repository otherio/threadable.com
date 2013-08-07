Feature: Authentication
  As a user with an account and a password
  I should be able to login with any of my email addresses
  And recover my password with any of my email addresses

Scenario: A user with an account and a password can sign in
  In order to use the site
  I'd like to keep my data associated with me
  Given I am not logged in
    And I go to the sign in page
    And I fill in "Email" with "alice@ucsd.covered.io"
    And I fill in "user_password" with "password"
    And I click the "Sign in" button
   Then I should see "Projects"
    And I should be on the home page
    And I should be logged in as "Alice Neilson"

Scenario: A user with an account and a password can sign in with any of their email addresses
  As a user with multiple email addresses
  I should be able to login with any of them.
  Given I am not logged in
    And I go to the sign in page
    And I click "Login"
    And I fill in "Email" with "ray@gmail.covered.io"
    And I fill in "user_password" with "password"
    And I click the "Sign in" button
   Then I should see "Projects"
    And I should be on the home page
    And I should be logged in as "Ray Arvidson"

Scenario: Failing to log in
  Given I am not logged in
    And I go to the sign in page
    And I click "Login"
    And I fill in "Email" with "alice@ucsd.covered.io"
    And I fill in "user_password" with "bullshitpassword"
    And I click the "Sign in" button
   Then I should see "Invalid email or password"

Scenario: Existing user forgot their password
  Given I am not logged in
   When I go to the sign in page
    And I click "Login"
    And I click "Forgot your password"
    And I fill in "Email" with "alice@ucsd.covered.io"
    And I click "Send me reset password instructions"
   Then I should see "You will receive an email with instructions about how to reset your password"

Scenario: Forgot password form should say it sent password reset instructions even if the email given doesnt exist
  Given I am not a member
   When I go to the sign in page
    And I click "Login"
    And I click "Forgot your password"
    And I fill in "Email" with "fakeuser@gmail.com"
    And I click "Send me reset password instructions"
   Then I should see "Notice! You will receive an email with instructions about how to reset your password in a few minutes."
