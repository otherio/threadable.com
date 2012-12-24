Feature: Tasks
 I should be able to create tasks, delete tasks, add myself as a doer for a task, add others as doers for a task, remove others as doers for a task, mark tasks as completed, and mark tasks as uncompleted.

Scenario: I want to add a registered user as a doer for a task
 In order to add a registered user as a doer for a task
 As a member of a project
 I should be able to add an registered user as a doer for a task
  Given I am "Slim"
    And I am logged in
    And I am a member of the project "build a huge wooden duck"
    And I am on the task page for "Buy a ton of wood"
   When I click on "Add Person"
    And I enter "Ian" in the name field
    And I enter "raindrift@sonic.net" in the email field
    And I leave the Doer/Follower toggle in its default state of "Doer"
    And I enter the comment "You said that you'd be willing to buy some wood for us. I donated 1/2 ton, could buy the rest?"
  And "raindrift@sonic.net" does not belong to a registered user
  Then "Ian" should be created as an unclaimed account
  And "Ian" should be added as a member of the project "build a huge wooden duck"
  And "Ian" should be added as a doer for the task "Buy a ton of wood"
  And an email should be sent to "raindrift@sonic.net" with the comment "You said that you'd be willing to buy some wood for us. I donated 1/2 ton, could buy the rest?"
  And a message should be displayed informing me that "Ian" has been added to the task and that an invitation email has been sent

  #RECHECK THIS WHOLE THING -- EDITED RADICALLY AT END OF DAY WHEN DISTRACTED
