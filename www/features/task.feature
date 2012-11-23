Feature: Task
  I should be able to work with tasks

  Scenario: I should be able to create a task

    Given I am logged in
    And there is a project called "BofA rebranding"
    When I click "add task"
    Then I should get a form asking me for the task name
    When I enter "Have a meeting" for the name
    And I click "create this task"
    Then I should see "Have a meeting" in the list of tasks

  Scenario: I should be able to complete a task

    Given I am logged in
    And there is a project called "BofA rebranding"
    And there is a task called "Have a meeting"
    When I click check the completed checkbox
    Then I should see the task disappear from the list

  Scenario: I should be able to see completed tasks

    Given I am logged in
    And there is a project called "BofA rebranding"
    And there is a task called "Design a sticker" which is completed
    When I click "show completed tasks"
    Then I should see "Design a sticker" in the list of tasks

  Scenario: I should be able to invite someone to do a task

    Given that I am logged in
    And there is a project called "BofA rebranding"
    And there is a task called "Have a meeting"
    When I click "Details" on "Have a meeting"
    Then I should see the "Invite" button
    When I click "Invite"
    Then I should see a form asking me for the invitee's email address
    When I enter "test@example.com" for the email address
    And I click "Send invitation"
    Then I should see "Your invitation has been sent"
    And the user "test@example.com" should receive an email
