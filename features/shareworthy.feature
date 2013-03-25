Feature: Shareworthy
  As a signed in person
  I want to be able to mark a message as shareworthy

@javascript
Scenario: marking a message as shareworthy
  Given I am "Tom Canver"
    And I go to the "layup body carbon" conversation for the "UCSD Electric Racing" project
   Then the first message should not be shareworthy
    And I click "shareworthy" within the first message
   Then the first message should be shareworthy
   When I reload the page
   Then the first message should be shareworthy
