Feature: Projects and Tasks
 I should be able to make and complete a task
 I should be able to sort tasks and see the completed ones
 I should be able to add doers, and view mine vs everyones tasks
 I should be able to invite someone to a task who isn't part of the project

#   Scenario: I want to create a task through the website
#     In order to create a task
#     As a member of a project
#     I should be able to create a task
#     Given that I am Alice the organizer
#       And I am on my project page
#       And I create a task called "machine adjustable seat rails"
#      Then a task called "machine adjustable seat rails" should be created in my project

#   Scenario: I want to complete a task through the website
#     As a member of a project
#     I should be able to complete a task
#     Given that I am Bob the machinist
#       And I am on my project page
#       And I open the "machine adjustable seat rails" task
#       And I mark the task as complete
#      Then the task "machine adjustable seat rails" should be marked as complete

#   Scenario: I want to un-complete a completed task
#     As a member of a project
#     I should be able to mark a task as not-complete
#     Given that I am Alice the organizer
#       And I am on my project page
#       And I open the "machine adjustable seat rails" task
#       And I mark the task as complete
#      Then the task "machine adjustable seat rails" should be not marked as complete

#   Scenario: I want to see completed vs incomplete tasks
#     As a member of a project
#     It should be clear which tasks remain incomplete
#     Given that I am Alice the organizer
#       And I am on my project page
#       And I mark the task "machine adjustable seat rails" as complete
#       And I create the task "weld seat rail mounts"
#      Then the task "weld seat rail mounts" should be in the "Unfinished" box
#       And the task "machine adjustable seat rails" should be in the "Complete" box

  @javascript
  Scenario: I want to add someone as a doer of a task
    As a member of the project
    I want to communicate other people's interest in a task
    Given I am "Alice Neilson"
      And I am on the task "install mirrors"
      And I add "Bethany" as a doer
     Then I should see "Bethany Pattern" as a doer of the task
    Given I am "Bethany Pattern"
      And I am on the task "install mirrors"
     Then I should see "remove myself"

#   Scenario: I want to order my tasklist
#     As a member of a project
#     I need to communicate priority of tasks
#     By changing their order
#     Given that I am Alice
#       And I am on my project page
#       And I create the task "mount seat"
#      Then I should be able to drag "mount seat" under "weld seat rail mounts"

#   Scenario: I want to add myself as a doer on a task through the website
#     As a member of a project
#     I want to be able to communicate my interest in a task
#     (to everyone, as well as myself)
#     Given I am Bob the machinist
#       And I am on my project page
#       And I click on the task "weld seat rail mounts"
#       And I click "sign me up"
#      Then I should see "weld seat rail mounts" in "my tasks"
#     Given I am Alice the organizer
#       And I am on my project page
#       And I click on the task "weld seat rail mounts"
#      Then I should see "Bob" as a doer of the task

#   Scenario: I want to view my tasks and all tasks
#     As a member of the project
#     I want to be able to see what I am working on, and what others are working on
#     Given I am Bob the Machinist
#       And I am on my project page
#       And I click all tasks
#      Then I should see the tasks "weld seat rail mounts" and "mount seats"
#       And I click my tasks
#      Then I should see only the task "weld seat rail mounts"

#   Scenario: I want to invite someone new to do a task
#     As a member of the project
#     I want to be able to ask for help from outside the projects membership
#     By inviting a new user to a task
#     Given I am Alice the organizer
#       And I am on the task "mount seats"
#       And I add "andyleesmith@gmail.com" to the task
#      Then I should see "andyleesmith@gmail.com" as a doer of the task
#      Then Andy should get an email with a link to the task "mount seats"
