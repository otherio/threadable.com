Feature: Everything
  As a non-member
  I should be able to create a project
  and a task
  and assign that task to friends


Scenario: common happy path
  Given I am not a member
   When I go to multify.com
    And I join with the following information:
      | name         | email             | password |
      | Jared Grippe | jared@example.com | flower   |
   Then I should be on the users page for "jared-grippe"
    And I should be logged in as "Jared Grippe"
   When I create a project called "build a huge wooden duck"
    And I create a task called "buy tons of wood"
    And I comment on that task "We need lots of wood to build this duck. lets get some. How about you, Slim?"
    And I add "slim@duckguy.org" as a doer to that task
   Then an email should be sent to "slim@duckguy.org"

  Given I am "slim"
    And I open my email
   Then I should see an email that says I have been added as a doer to the task "buy tons of wood" for the project "build a huge wooden duck"
   When I click "sign up"
   Then I should be on the claim your account page
   When I fill in "password" with "duckie"
    And I fill in "name" with "slim"
    And I press "login"
   Then I should be on the task page for "buy tons of wood" for the project "build a huge wooden duck"
    And I comment on that task "Great. I can only get 1 ton now. I'll add Ian to get the other ton."
    And an email should be sent to "jared@example.com" with the comment "Great. I can only get 1 ton now. I'll add Ian to get the other ton."
    And I add "ian@sonic.net" as a doer to this task
   Then an email should be sent to "ian@sonic.net"

  Given I am "ian"
    And I open my email
   Then I should see an email that says I have been added as a doer to the task "buy tons of wood" for the project "build a huge wooden duck"
   When I click "sign up"
   Then I should be on the claim your account page
   When I fill in "password" with "omgzyoomg"
    And I fill in "name" with "ian"
    And I press "login"
   Then I should be on the task page for "buy tons of wood" for the project "build a huge wooden duck"
    And I comment on that task "I bought the other ton. It's very heavy."
    And an email should be sent to "jared@example.com, slim@duckguy.org" with the comment "I bought the other ton. It's very heavy."
   Then I check "completed"
    And an email should be sent to "jared@example.com, slim@duckguy.org" saying the task "buy tons of wood" for the project "build a huge wooden duck" is complete
    And I log out

  Given I am a member of Multify
     And I am member of the project "build a huge wooden duck"
     And I am logged in
     And I am on the project page for "build a huge wooden duck"
    Then I should be able to add "duckexpert@geocities.com" as a member of this project
    Then an email should be sent to "duckexpert@geocities.com"
      And "duckexpert@geocities.com" should be able to join Multify
      And "duckexpert@geocities.com" should be able to create or comment on tasks


