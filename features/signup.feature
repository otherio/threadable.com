Feature: Signup
  As a new user
  I should be able to signup

Scenario: Signing up
  When I signup with the following information:
    | Name  | Weird Al Yankovik     |
    | Email | weird.al@yankovik.com |
  Then I should see "Thanks for signing up!"
   And I should see "We just sent you an email with a link to confirm your email address and set a password for your account."
   And I a confirmation link should have been sent to "weird.al@yankovik.com"
  When I click the validation link sent to "weird.al@yankovik.com"
  Then I should see "You're almost done!"
  When I click the "Sign in" button
  Then I should see "Password can't be blank"
  When I fill in the password fields with "ilovepizza" and "ilovepizz"
  When I click the "Sign in" button
  Then I should see "Password confirmation doesn't match Password"
  When I fill in the password fields with "ilovepizza"
   And I click the "Sign in" button
  Then I should see "Your account was successfully confirmed. You are now signed in."
   And I should be logged in as "Weird Al Yankovik"


Scenario: Account creation fails if email is already used
  If an account already exists for this email address
  I should not be able to create another one
  Given I am not logged in
    And I go to the join page
    And I fill in "Name" with "Alice Neilson"
    And I fill in "Email" with "alice@ucsd.covered.io"
    And I click the "Sign up" button
   Then I should see "Email has already been taken"

@email
Scenario: When added to a project, a new user receives a welcome email
  Given I am "Alice Neilson"
    And I invite "Bob", "bob@example.com" to the "UCSD Electric Racing" project
   Then "bob@example.com" should have received an email containing the text: "You've been added to the UCSD Electric Racing project on Covered"


Scenario: A new user can request an invite to create a project via the website

Scenario: A new user can accept an invite to create a project

Scenario: A new user can signup via their facebook account

Scenario: A new user can signup via their google account

Scenario: A new user can confirm their email during the signup process

Scenario: A new user that accepts an invitiation to a project can choose to signup via the confirmation page ("you can do this at any time!")

Scenario: An email-only user can set a password by following any covered link in their email.

Scenario: An email-only user can set a password via the website
