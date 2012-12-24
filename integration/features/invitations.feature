Feature: Invitations
 I should be able to invite unregistered users to join the site, either by adding them as members a project, adding them as doers for a task, or adding them as followers of a task. The people I invite should be able to use those invitations to claim their accounts and become registered users.

Scenario: I want to add an unregistered user as a member of a project
 In order to add an unregistered user as a member of a project
 As a member of that project
 I should be able to add an unregistered user to the project and send them an invitation
  Given I am "Jared"
    And I am logged in
    And I am a member of the project "build a huge wooden duck"
    And I am on the project page for the project "build a huge wooden duck"
   When I click on "Add Person"
    And I enter "Slim" in the name field
    And I enter "sfslim@gmail.com" in the email field
    And I enter "Hey Slim — We're trying to build a huge wooden duck. I seem to recall you have some experience doing this. Care to lend a hand?" in the comment field
    And "sfslim@gmail.com" does not belong to a registered user
    Then "Slim" should be created as an unclaimed account
    And "Slim" should be added as a member of the project "build a huge wooden duck"
    And an email should be sent to "sfslim@gmail.com" with the comment "Hey Slim — We're trying to build a huge wooden duck. I seem to recall you have some experience doing this. Care to lend a hand?"
    And a message should be displayed informing me that "Slim" has been added to the project and that an invitation email has been sent

Scenario: I want to claim an account via a project member invitation
 In order to claim an account via a project member invitation
 As an unregistered user
 I should be able to respond to an email, register, and end up at that project 
  Given I am "Slim"
    And I am an unregistered user
    And "Jared" has added me as a member of the project "build a huge wooden duck"
    And the account "sfslim@gmail.com" is unclaimed
    And an invitation email has been sent to me
    When I open my email
    Then I should see an email that says I have been added as a member of the project "build a huge wooden duck" with the comment "Hey Slim — We're trying to build a huge wooden duck. I seem to recall you have some experience doing this. Care to lend a hand?"
    When I click "Sign up"
    Then I should be on the claim your account page
    When I register with the following information:
      | name     | email             | password                  |
      | Slim     | sfslim@gmail.com  | correcthorsebatterystaple |
    Then "Slim" should be a registered user
    And the account "Slim" should be claimed
    And I should be on the project page for "build a huge wooden duck"
    And an email should be sent to "Slim" notifying me that my account has been created and welcoming me to the site
    And an email should be sent to "Jared" notifying him that "SFSlim" has accepted the invitation he sent to "sfslim@gmail.com" for the project "build a huge wooden duck"

Scenario: I want to add an unregistered user as a doer for a task
 In order to add an unregistered user as a doer for a task
 As a member of a project
 I should be able to add an unregistered user as a doer and send them an invitation
Given I am "Jared"
  And I am logged in
  And I am a member of the project "build a huge wooden duck"
  And I am on the task page for "Buy a ton of wood"
 When I click on "Add Person"
  And I enter "Slim" in the name field
  And I enter "sfslim@gmail.com" in the email field
  And I leave the Doer/Follower toggle in its default state of "Doer"
  And I enter the comment "Do you have any wood left over in storage?"
  And "sfslim@gmail.com" does not belong to a registered user
  Then "Slim" should be created as an unclaimed account
  And "Slim" should be added as a member of the project "build a huge wooden duck"
  And "Slim" should be added as a doer for the task "Buy a ton of wood"
  And an email should be sent to "slim@gmail.com" with the comment "Do you have any wood left over in storage?"
  And a message should be displayed informing me that "Slim" has been added to the task and that an invitation email has been sent

Scenario: I want to claim an account via a task doer invitation
 In order to claim an account via a task doer invitation
 As an unregistered user
 I should be able to respond to an email, register, and end up at that task 
  Given I am "Slim"
    And I am an unregistered user
    And "Jared" has added me as a doer for the task "Buy a ton of wood"
    And the account "sfslim@gmail.com" is unclaimed
    And an invitation email has been sent to me
    When I open my email
    Then I should see an email that says I have been added as a doer to the task "Buy a ton of wood" for the project "build a huge wooden duck" with the comment "Do you have any wood left over in storage?"
    When I click "Sign up"
    Then I should be on the claim your account page
    When I register with the following information:
      | name     | email             | password                  |
      | Slim     | sfslim@gmail.com  | correcthorsebatterystaple |
    Then "Slim" should be a registered user
    And the account "Slim" should be claimed
    And I should be on the task page for "buy 2 tons of wood" for the project "build a huge wooden duck"
    And an email should be sent to "Slim" notifying me that my account has been created and welcoming me to the site
    And an email should be sent to "Jared" notifying him that "SFSlim" has accepted the invitation he sent to "sfslim@gmail.com" for the task "buy tons of wood" on the project "build a huge wooden duck"

Scenario: I want to add an unregistered user as a follower of a task
 In order to add an unregistered user as a follower of a task
 As a member of a project
 I should be able to add an unregistered user as a follower and send them an invitation
Given I am "Jared"
  And I am logged in
  And I am a member of the project "build a huge wooden duck"
  And I am on the task page for "Draft grant application"
 When I click on "Add Person"
  And I enter "Slim" in the name field
  And I enter "sfslim@gmail.com" in the email field
  And I set the Doer/Follower toggle to "Follower" 
  And I enter the comment "Per our discussion yesterday, you wanted to keep tabs on our progress re: the grant application."
  And "sfslim@gmail.com" does not belong to a registered user
  Then "Slim" should be created as an unclaimed account
  And "Slim" should be added as a member of the project "build a huge wooden duck"
  And "Slim" should be added as a follower of the task "Draft grant application"
  And an email should be sent to "slim@gmail.com" with the comment "Per our discussion yesterday, you wanted to keep tabs on our progress re: the grant application."
  And a message should be displayed informing me that "Slim" has been added to the task and that an invitation email has been sent

