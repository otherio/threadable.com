Feature: User Accounts
  I should be able to get an account and login and logout and everything that you'd expect from a website.

  Scenario: When I want to join through the join form
    In order to join the site
    As a non-member
    I should be able to create an account
    Given I am not a member
     When I go to multify.com
      And I join with the following information:
        | name         | email             | password |
        | Jared Grippe | jared@example.com | flower   |
     Then I should be on the users page for "jared-grippe"
      And I should be logged in as "Jared Grippe"

  Scenario: When I want to login with my existing account
    In order to log in
    As a member of the site
    I should be able to log in
    Given that I am "Jared"
      And I am not logged in
     When I go to multify.com
      And I login with the following information:
        | email             | password |
        | jared@example.com | flower   |
     Then I should be logged in as "Jared Grippe"

  Scenario: When I want to logout
    In order to log out
    As a member of the site
    I should be able to log out
    Given that I am "Jared"
       And I am logged in
      When I logout
      Then I should be logged out
