Feature: Joining
  I should totally be able to join

  Scenario: when I am added as a doer to a task I should be emailed about that and be able to join and view the task

    Given my email address is "test@example.com"
    And there is a project called "BofA rebranding"
    And there is a task "arrange a work night" for the project "BofA rebranding"
    When I am added as a doer to the task "arrange a work night" for the project "BofA rebranding"
    Then I should get an email sent to "test@example.com"
    When I open that email
    Then I should see "arrange a work night"
    When I click the "do this task" link
    Then I should be on the join page
    And I should see "please give us a password"
    When I enter "foo" into the password field
    And I press join
    Then I should see "welcome, you now have an account"
    And I should see "arrange a work night"
    And I should be a doer of this task


  Scenario: when I am added as a follower to a task I should be emailed about that and be able to join and view the task

    Given my email address is "test@example.com"
    And there is a project called "BofA rebranding"
    And there is a task "arrange a work night" for the project "BofA rebranding"
    When I am added as a follower to a task
    Then I should get an email sent to "test@example.com"
    When I open that email
    Then I should see "arrange a work night"
    When I click the "do this task" link
    Then I should be on the join page
    And I should see "please give us a password"
    When I enter "foo" into the password field
    And I press join
    Then I should see "welcome, you now have an account"
    And I should see "arrange a work night"
    And I should be a follower of this task
