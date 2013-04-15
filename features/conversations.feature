Feature: Conversations
  I should be able to make new conversations and send messages by email and the web
  I should be able to view messages by email and the web
  I should be able to see conversation events

  @javascript
  Scenario: Viewing conversations with quoted text
    As a member of a project
    I should be able to expand collapsed quoted text
    Given I am "Alice Neilson"
      And I go to the "layup body carbon" conversation for the "UCSD Electric Racing" project
     Then a message should have hidden quoted text
     When I click the "..." button
     Then a message should have visible quoted text

#  Scenario: I want to create a new conversation through the website
#     As a member of a project
#     I should be able to start a new conversation
#     Given that I am Alice the organizer
#       And I am on my project page
#       And I create a conversation titled "how are we going to build the body"
#       And enter the message "should we make it out of cardboard or carbon fiber?"
#      Then a conversation titled "how are we going to build the body" should be created in my project
#       And an email titled "how are we going to build the body" should be sent to all project members

#   Scenario: I want to create a new conversation from email
#     As a member of a project
#     I should be able to start a new conversation
#     Given that I am Alice the organizer
#       And I send an email titled "what do we want for dinner" with the message "any ideas?"
#      Then a conversation titled "what do we want for dinner" should be created in my project
#       And an email titled "what do we want for dinner" should be sent to all project members

#   Scenario: I want to view messages through the website
#     As a member of a project
#     I should be able to view messages
#     Given that I am Bob the machinist
#       And I am on my project page
#      Then I should see conversations titled "how are we going to build the body" and "what do we want for dinner" in the conversations box
#      When I open "what do we want for dinner"
#      Then I should see the message "any ideas?"

#   Scenario: I want to see conversation events
#     As a member of a project
#     In order to learn what actions have occured during that conversation
#     I should be able to see those actions within the conversation
#     Given that I am Bob the machinist
#       And I am on the conversation for the "weld seat rail mounts" task
#      Then I should see that Alice created this task
#       And I should see that I added myself as a doer of this task
#      When I mark this task as complete
#      Then I should see that I completed this task
