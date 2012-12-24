Feature: Project Creation
  In order to create a project
  As a member of the site
  I should be able to create a project
Scenario: Project Creation
Given that I am "Jared"
       And I am logged in
      When I create a project called "build a huge wooden duck"
      Then the project called "build a huge wooden duck" should be created

Feature: Task Creation
  In order to create a task
  As a member of a project
  I should be able to create a task
Scenario: Task Creation
Given that I am "Jared"
       And I am logged in
       And I am on the page for the project "build a huge wooden duck"
       And I create a task called "buy tons of wood"
       Then a task called "buy tons of wood" should be created in the project "build a huge wooden duck"

Feature: Adding doers to tasks
  In order to assign tasks to others
  As a member of a project
  I should be able to assign doers to tasks
Scenario: Adding doers to tasks
Given that I am "Jared"
       And I am logged in
       And I am on the task page for "buy tons of wood"
      When I click on "Add doer"
       And I enter "sfslim@gmail.com" in the email field
       And I enter the comment "We need lots of wood to build this duck. lets get some. How about you, Slim?"
      Then "slim" should be added as a member of the project "build a huge wooden duck"
       And "slim" should be added as a doer for the task "buy tons of wood"
       And an email should be sent to "slim@gmail.com" with the comment "We need lots of wood to build this duck. lets get some. How about you, Slim?"

Feature: Claiming accounts
  In order to accept an invitation
  As a non-member
  I should be able to join the site by responding to an email invitation
Scenario: Claiming an account via an email invitation
Given that I am "slim"
       And I open my email
      Then I should see an email that says I have been added as a doer to the task "buy tons of wood" for the project "build a huge wooden duck" with the comment "We need lots of wood to build this duck. lets get some. How about you, Slim?"
      When I click "Sign up"
      Then I should be on the claim your account page
      When I fill in "password" with "duckie"
       And I fill in "name" with "slim"
       And I click "login"
      Then I should be on the task page for "buy 2 tons of wood" for the project "build a huge wooden duck"

Feature: Emailing comments
  In order to communicate about a task
  As a doer of that task
  I should be able to comment on a task, and have that comment sent as email to other doers of that task
Scenario: Commenting on a task
Given that I am "Slim"
      When I add a comment to the task "buy tons of wood" that reads "Ok. But I can only afford to buy 1 ton right now."
      Then an email should be sent to "jared@example.com" with the comment "Ok. But I can only afford to buy 1 ton right now."

Feature: Doers adding doers to tasks
  In order to have multiple doers for a given task
  As a doer
  I want to be able to add other doers to tasks
Scenario: Add a doer to a task
Given that I am "Slim"
      When I add "ian@sonic.net" as a doer to the task "buy 2 tons of wood" with the comment "Ian, I'm working on the project 'build a huge wooden duck'. When we last spoke, you said that you'd be willing to buy some wood for us. I bought the first ton, could you sign up and buy the rest?"
      Then an email should be sent to "ian@sonic.net" with the comment "Ian, I'm working on the project 'build a huge wooden duck'. When we last spoke, you said that you'd be willing to buy some wood for us. I bought the first ton, could you sign up and buy the rest?"
Given that I am "Ian"
       And I open my email
      Then I should see an email that says I have been added as a doer to the task "buy tons of wood" for the project "build a huge wooden duck" with the comment "Ian, I'm working on the project 'build a huge wooden duck'. When we last spoke, you said that you'd be willing to buy some wood for us. I bought the first ton, could you sign up and buy the rest?"
      When I click "Sign up"
      Then I should be on the claim your account page
      When I fill in "password" with "omgzyoomg"
       And I fill in "name" with "ian"
       And I click "login"
      Then I should be on the task page for "buy tons of wood" for the project "build a huge wooden duck"
       And I comment on that task "I bought the other ton. It's very heavy."
       And an email should be sent to "jared@example.com, slim@gmail.com" with the comment "I bought the other ton. It's very heavy."

Feature: Marking a task as complete
  In order to mark a given task as complete
  As a doer on a given task
  I want to be able to mark that task as "Completed"
Scenario: Marking as task as complete
Given that I am "Ian"
       And I am logged in
       And I am on the task page for "buy tons of wood"
      When I click "Completed"
      Then the task "buy tons of wood" should be marked as completed
      And an email should be sent to "jared@example.com, slim@gmail.com" saying the task "buy tons of wood" for the project "build a huge wooden duck" is complete
   
Feature: Inviting a user to a project
  In order to invite a user to a whole project rather than as a doer on a specific task
  As a existing member of that project
  I want to invite a user to a project
Scenario: Inviting a user to a project
Given that I am "Ian"
       And I am logged in
       And I am on the project page for the project "build a huge wooden duck"
      When I add "duckexpert@geocities.com" as a member of this project with the comment "Hi Noah! I'm working on the project 'Build a huge wooden duck.' As the world's foremost expert on massive wooden waterfowl, your feedback on this project would be invaluable. Please consider signing up and taking a look at what we're doing."
      Then I should see a message that "duckexpert@geocities.com" has been added as a member of the project "build a huge wooden duck"
Given that I am "Noah"
       And I open my email
      Then I should see an email that says I have been added as a member of the project "build a huge wooden duck" with the comment "Hi Noah! I'm working on the project 'Build a huge wooden duck.' As the world's foremost expert on massive wooden waterfowl, your feedback on this project would be invaluable. Please consider signing up and taking a look at what we're doing."
      When I click "Sign up"
      Then I should be on the claim your account page
      When I fill in "password" with "123456"
       And I fill in "name" with "Noah"
       And I press "login"
      Then I should be on the project page for "build a huge wooden duck"


Feature: Minimum password length
  In order to ensure that I select minimally secure passwords
  As a non-member
  I want to be required to enter a password that is at least 8 characters in length
Scenario: Checking the length of a password
INCOMPLETE 
