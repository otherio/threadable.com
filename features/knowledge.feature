Feature: Knowledge
  As a signed in person
  I want to be able to mark a message as knowledge

@javascript
Scenario: marking a message as knowledge
  Given I am "Tom Canver"
    And I go to the "layup body carbon" conversation for the "UCSD Electric Racing" project
   Then the first message should not be knowledge
    And I click "knowledge" within the first message
   Then the first message should be knowledge
   When I reload the page
   Then the first message should be knowledge
