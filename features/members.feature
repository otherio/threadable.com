Feature: Members List
  I should be able to see a list of members for the current project

  @javascript
  Scenario: I want to see a list of members for the current project
    Given I am "Alice Neilson"
     When I go to the project conversations page for "UCSD Electric Racing"
      And I click "Members"
     Then I should see "Tom Canver"