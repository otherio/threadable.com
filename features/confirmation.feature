Feature: Confirmation

Scenario: Confirming an account without a password
   When I click an account confirmation link for "alice@ucsd.covered.io"
   Then I should see "Your account has been confirmed!"
    And I should be on the sign in page prefilled with "alice@ucsd.covered.io"

Scenario: Confirming an account with a password
   When I click an account confirmation link for "jonathan@ucsd.covered.io"
   Then I should see "Your account has been confirmed!"
    And I should be on the user setup page
    And I should not be signed in
