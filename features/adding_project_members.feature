Feature: Adding project members
  As a member of a project I should be able to add members to said project.

  Scenario: adding an unregistered user to a project
    In order to add an unregistered user as a member to my project
    As a member of that project
    I should be able to add an unregistered user to the project and send them an invitation
    Given I am "Alice Neilson"
     When I add "Frank Zappa", "frank@zappaworld.net" to the "UCSD Electric Racing" project
     Then I should see "Hey! Frank Zappa <frank@zappaworld.net> was added to this project."

  Scenario: adding an existing user to a project
    As a member of a project
    I should get a notification if I try to add an existing member.
    Given I am "Alice Neilson"
     When I add "Yan Zhu", "yan@ucsd.covered.io" to the "UCSD Electric Racing" project
     Then I should see "Notice! That user is already a member of this project."

  Scenario: being added to a project
    When "Alice Neilson" adds "Archimedes Vanderhimen" "archimedes@ucsd.covered.io" to the "UCSD Electric Racing" project:
      """
      We need your sick driving skills!
      """
    Then "archimedes@ucsd.covered.io" should have recieved a join notice email for the "UCSD Electric Racing" project
    When I click the project link in the join notice email sent to "archimedes@ucsd.covered.io" for the "UCSD Electric Racing" project
    Then I should be on the user setup page
     And I should see "You're almost in!"
     And the "Name" field should be filled in with "Archimedes Vanderhimen"
     And the "Password" field should be blank
     And the "Password confirmation" field should be blank
    When I fill in "Name" with "Archimedes Van-Dérhimen"
     And I fill in "Password" with "password"
     And I fill in "Password confirmation" with "password"
     And I click "Setup my account"
    Then I should be on the project conversations page for "UCSD Electric Racing"
     And I should be signed in as "Archimedes Van-Dérhimen"
