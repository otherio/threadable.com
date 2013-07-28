Feature: Projects and Tasks
  As a member of a project
  I should be able to make and complete a task
  I should be able to sort tasks and see the completed ones
  I should be able to add doers, and view mine vs everyones tasks
  I should be able to invite someone to a task who isn't part of the project

  @javascript
  Scenario: Creating, asigning and completing a task for an existing project
    Given I am "Tom Canver"
     When I go to the project conversations page for "UCSD Electric Racing"
      And I add a new task titled "Research carbon fiber techniques"
     Then I should see "Research carbon fiber techniques" within the not done tasks list
     When I click "Research carbon fiber techniques" within the not done tasks list
     Then I should be on the "Research carbon fiber techniques" conversation page
     When I add "Yan Hzu" as a doer for this task
     Then I should see "Yan Hzu" within the list of doers for this task
     When I click "My Tasks" within the tasks sidebar
     Then I should not see "Research carbon fiber techniques" within the tasks sidebar
     When I click "sign me up"
     Then I should see "Tom Canver" within the list of doers for this task
      And I should see "Research carbon fiber techniques" within the tasks sidebar

  @javascript
  Scenario: I want to add someone as a doer of a task
    As a member of the project
    I want to communicate other people's interest in a task
    Given I am "Alice Neilson"
      And I am on the task "install mirrors"
     When I add "Bethany Pattern" as a doer for this task
     Then I should see "Bethany Pattern" as a doer of the task


  @javascript
  Scenario: I want to remove someone as a doer of a task
    As a member of the project
    I want to communicate other people's interest in a task
    Given I am "Alice Neilson"
      And I am on the task "layup body carbon"
     When I remove "Yan Hzu" as a doer for this task
     Then I should not see "Yan Hzu" as a doer of the task




  Scenario: A signed in user can create a task via email

  Scenario: A signed in user can create a task via the website

  Scenario: A signed in user can add or remove themselves from a task via email

  Scenario: A signed in user can add or remove themselves from a task via website
    Given I am "Alice Neilson"
      And I go to the "install mirrors" task page
      And I click "sign me up"
     Then I should see "you have been added as a doer"
     When I click "remove me"
     Then I should see "you have been removed as a doer"

  Scenario: A signed in user can mark a task done or undone from via email

  Scenario: A signed in user can mark a task done or undone from via the website
