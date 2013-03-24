Feature: Signup
  As a random person
  I want to be able to sign up

Scenario: Signing up
  When I signup with the following information:
    | Name  | Weird Al Yankovik     |
    | Email | weird.al@yankovik.com |
  Then I should see "A message with a confirmation link has been sent to your email address. Please open the link to activate your account."
   And I a confirmation link should have been sent to "weird.al@yankovik.com"
  When I click the validation link sent to "weird.al@yankovik.com"
  Then I should see "You're almost done! Now create a password to securely access your account."
  When I click "Confirm Account"
  Then I should see "Password can't be blank"
  When I fill in the password fields with "ilovepizza" and "ilovepizz"
  When I click "Confirm Account"
  Then I should see "Password doesn't match confirmation"
  When I fill in the password fields with "ilovepizza"
   And I click "Confirm Account"
  Then I should see "Your account was successfully confirmed. You are now signed in."
  Then I should be logged in as "Weird Al Yankovik"

Scenario: Account creation fails if email is already used
  If an account already exists for this email address
  I should not be able to create another one
  Given I am not logged in
    And I go to the join page
    And I fill in "Name" with "Alice Neilson"
    And I fill in "Email" with "alice@ucsd.multifyapp.com"
    And I click "Sign up"
   Then I should see "Email has already been taken"
