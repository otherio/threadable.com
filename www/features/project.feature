@javascript
Feature: Project
  I should be able to interact with projects

  Scenario: I should be able to create a project
    Given I am logged in as:
      | name         | email             | password |
      | Jared Grippe | jared@example.com | flower   |
    When I create the following project:
      | name            | slug            | description                |
      | Kill all Humans | kill-all-humans | We will use climate change |
    Then I should be on the project page for "kill-all-humans"
     And I should see "Kill all Humans"
     And I should see "We will use climate change"

  # Scenario: I should be able to view a project's info

  #   Given I am logged in
  #   And there is a project called "Kill all humans"
  #   Then I should see "We will use climate change"

  # Scenario: I should be able to invite someone to a project

  #   Given that I am logged in
  #   And there is a project called "Kill all humans"
  #   And I click "Invite"
  #   Then I should see a list of current project members
  #   And I should see a form asking me for the invitee's email address
  #   When I enter "test@example.com" for the email address
  #   And I click "Send invitation"
  #   Then I should see "Your invitation has been sent"
  #   And the user "test@example.com" should receive an email
