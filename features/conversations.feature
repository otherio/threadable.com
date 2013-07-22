Feature: Conversations
  I should be able to make new conversations and send messages by email and the web
  I should be able to view messages by email and the web
  I should be able to see conversation events

  Scenario: Viewing conversations with quoted text
    As a member of a project
    I should be able to expand collapsed quoted text
    Given I am "Alice Neilson"
      And I go to the "layup body carbon" conversation for the "UCSD Electric Racing" project
     Then I should see "This turned out super awesome! Yan"
      But I should not see "> Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass"
     When I show the quoted text for the message containing "This turned out super awesome! Yan"
     Then I should see "> Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass"

  @javascript
  Scenario: Posting a new message in a conversation
    As a member of a project
    I should be able to post messages to a conversation, and people should receive them.
    Given I am "Alice Neilson"
      And I go to the "layup body carbon" conversation for the "UCSD Electric Racing" project
     When I send the message "This looks great!"
     Then I should see "This looks great!"



  Scenario: A signed in user can receive emails for each message in all coversations of all projects

  Scenario: A signed in user can post a message to a conversation by replying to a conversation message email

  Scenario: A signed in user can mute a conversation via email

  Scenario: A signed in user can mute a conversation via the website

  Scenario: A signed in user can read conversation messages in their email in html or plain text

  Scenario: A signed in user can see who will recieve a message before they send it

  Scenario: A signed in user can see if a converation message has been read or not via the website in a list of conversations

  Scenario: A signed in user can see if a converation message has been read or not via the website in a list of conversation messages

  Scenario: A signed in user can mark a message as unread via the website

  Scenario: A signed in user can automatically mark a message as read via the website

  Scenario: A signed in user can automatically mark a message as read via email

  Scenario: A signed in user can filter the list of conversations via the website

  Scenario: A signed in user can filter the list of tasks via the website

  Scenario: A signed in user can search the content of a project


