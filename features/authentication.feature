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
  I should be able to create an account
  with a valid email address
  that isn't already used
  and the password fields match
  Given I am not a member
   When I go to the join page
    And I fill in "Email" with "audrey.penven@gmail.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I click "Sign up"
   Then I should see "You have signed up successfully"

Scenario: Account creation fails if passwords don't match
  I should not be able to create an account if the password and passowrd confirmation don't match
  Given I am not a member
   When I go to the join page
    And I fill in "Email" with "audrey.penven@gmail.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "nonmatchingpassword"
    And I click "Sign up"
   Then I should see "Password doesn't match confirmation"

Scenario: Account creation fails if email is already used
  If an account already exists for this email address
  I should not be able to create another one
  Given the following users:
    | Name          | Email                  | Password |
    | Existing User | existinguser@gmail.com | password |
   When I am not logged in
    And I go to the join page
    And I fill in "Email" with "existinguser@gmail.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I click "Sign up"
   Then I should see "Email has already been taken"

Scenario: Forgot password form works for existing users
  If I have an account
  and I forget my password
  I should be able to reset it
  Given this scenario is pending because of a lame devise bug
  Given the following users:
    | Name               | Email                       | Password |
    | Password Forgetter | existinguser1@gmail.com | password |
   When I am not logged in
    And I go to the home page
    And I click "Login"
    And I click "Forgot your password"
    And I fill in "Email" with "existinguser1@gmail.com"
    And I click "Send me reset password instructions"
   Then I should see "You will receive an email with instructions about how to reset your password"

Scenario: Forgot password form should notify the user if an account doesn't exist with the specified email address
  If I do not have an account
  and I try to use the forgot password form
  I should see an error
  Given I am not a member
   When I go to the home page
    And I click "Login"
    And I click "Forgot your password"
    And I fill in "Email" with "fakeuser@gmail.com"
    And I click "Send me reset password instructions"
   Then I should see "Email not found"
