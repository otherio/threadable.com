@javascript
Feature: Joining
  I should totally be able to join

  Scenario: When I want to join through the basic web form

    # When I go to the join page
    When I join with the following information:
      | name         | email             | password |
      | Jared Grippe | jared@example.com | flower   |
    Then I should be on the users page for "jared-grippe"
     And I should be logged in as "Jared Grippe"
    When I log out
     And I log in as "jared@example.com" with the password "flower"
    Then I should be logged in as "Jared Grippe"

  # Scenario: when I am add as a doer to a task I should be emailed about that and be able to join and view the task

  #   Given the following users:
  #     | name  | email             | password |
  #     | Jared | jared@example.com | flower   |
  #    And the following projects:
  #     | name            | slug            |
  #     | Save The Whales | save-the-whales |
  #    And the following tasks:
  #     | project         | name       | slug       |
  #     | Save The Whales | Buy a boat | buy-a-boat |
  #    When I login as "jared@example.com"
  #     And I add "nicole@example.com" as a doer to the "buy-a-boat" task of the "save-the-whales" project
  #     # And I go to the task page for the "Buy a boat" task of the "Save The Whales" project
  #     # And I click "add doer"




  #   Given my email address is "test@example.com"
  #   And there is a project called "BofA rebranding"
  #   And there is a task "arrange a work night" for the project "BofA rebranding"
  #   When I am added as a doer to the task "arrange a work night" for the project "BofA rebranding"
  #   Then I should get an email say I was added as a doer to the task "arrange a work night" for the project "BofA rebranding"
  #   When I open that email
  #   Then I should see "arrange a work night" within the email
  #   When I click the "do this task" link within the email
  #   Then I should be on the join page
  #   And I should see "please give us a password"
  #   When I enter "foo" into the password field
  #   And I press join
  #   Then I should see "welcome, you now have an account"
  #   And I should see "arrange a work night"
  #   And I should be a doer of this task


  # Scenario: when I am added as a follower to a task I should be emailed about that and be able to join and view the task

  #   Given my email address is "test@example.com"
  #   And there is a project called "BofA rebranding"
  #   And there is a task "arrange a work night" for the project "BofA rebranding"
  #   When I am added as a follower to the task "arrange a work night" for the project "BofA rebranding"
  #   Then I should get an email say I was added as a follower to the task "arrange a work night" for the project "BofA rebranding"
  #   When I open that email
  #   Then I should see "arrange a work night" within the email
  #   When I click the "follow this task" link within the email
  #   Then I should be on the join page
  #   And I should see "please give us a password"
  #   When I enter "foo" into the password field
  #   And I press join
  #   Then I should see "welcome, you now have an account"
  #   And I should see "arrange a work night"
  #   And I should be a follower of this task
