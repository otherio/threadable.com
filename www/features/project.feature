Feature: Project
  I should be able to interact with projects

  Scenario: I should be able to create a project

    Given I am logged in
    When I click "create project"
    Then I should get a form asking me for the project name and description
    When I enter "Kill all humans" for the name
    And I enter "We will use climate change, since it allows us to be lazy" for the description
    And I press "Create this project"
    Then I should see "your project has been created"

  Scenario: I should be able to view a project's info

    Given I am logged in
    And there is a project called "Kill all humans"
    Then I should see "We will use climate change"

  Scenario: I should be able to invite someone to a project

    Given that I am logged in
    And there is a project called "Kill all humans"
    And I click "Invite"
    Then I should see a list of current project members
    And I should see a form asking me for the invitee's email address
    When I enter "test@example.com" for the email address
    And I click "Send invitation"
    Then I should see "Your invitation has been sent"
    And the user "test@example.com" should receive an email
