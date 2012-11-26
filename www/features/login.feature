@javascript
Feature: Login
  I should totally be able to log in

  Scenario: When I want to login through the basic web form

    Given the following users:
      | name         | email             | password |
      | Jared Grippe | jared@example.com | flower   |
    When I log in as "jared@example.com" with the password "flower"
    Then I should be logged in as "Jared Grippe"

  Scenario: When I login with an account that does not exist
    When I log in as "notauser@example.com" with the password "nopenothere"
    Then I should see "Login Failed"

