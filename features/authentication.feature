Feature: Authentication
  As a user with an account and a password
  I should be able to sign in with any of my email addresses
  And recover my password with any of my email addresses

Scenario: A user with an account and a password can sign in
  In order to use the site
  I'd like to keep my data associated with me
  Given I am not logged in
    And I go to the sign in page
    And I fill in "Email" with "alice@ucsd.covered.io"
    And I fill in "Password" with "password"
    And I click the "Sign in" button
   Then I should see "Projects"
    And I should be on the home page
    And I should be signed in as "Alice Neilson"

Scenario: A user with an account and a password can sign in with any of their email addresses
  As a user with multiple email addresses
  I should be able to sign in with any of them.
  Given I am not logged in
   When I go to the sign in page
    And I fill in "Email" with "ray@gmail.covered.io"
    And I fill in "Password" with "password"
    And I click the "Sign in" button
   Then I should see "Projects"
    And I should be on the home page
    And I should be signed in as "Ray Arvidson"

Scenario: Failing to log in
  Given I am not logged in
    And I go to the sign in page
    And I fill in "Email" with "alice@ucsd.covered.io"
    And I fill in "Password" with "bullshitpassword"
    And I click the "Sign in" button
   Then I should see the sign in form shake

Scenario: Existing user with a password forgot their password
  Given I am not logged in
   When I go to the sign in page
    And I click "Forgot password"
   Then I should see "Recover password"
   When I fill in "Email" with "alice@ucsd.covered.io"
    And I click the "Recover" button
   Then I should see "We've emailed you a password recovery link. Please check your email."

Scenario: Existing user without a password forgot their password
  Given I am not logged in
   When I go to the sign in page
    And I click "Forgot password"
   Then I should see "Recover password"
   When I fill in "Email" with "jonathan@ucsd.covered.io"
    And I click the "Recover" button
   Then I should see "We've emailed you a link to setup your account. Please check your email."

Scenario: Unknown user forgot their password
  Given I am not a member
   When I go to the sign in page
    And I click "Forgot password"
   Then I should see "Recover password"
   When I fill in "Email" with "fakeuser@gmail.com"
    And I click the "Recover" button
   Then I should see "Error! No account found with that email address"
