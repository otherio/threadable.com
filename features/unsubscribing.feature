Feature: Unsubscribing
 I should be able to stop getting email if I am tired of it, and undo that sort of thing.
 I should also be able to turn that shit back on later.

 Scenario: Clicking the unsubscribe link in my email
    When I follow the unsubscribe link in an email to "Alice Neilson" and from the project "UCSD Electric Racing"
    Then I should see "We just unsubscribed Alice Neilson from UCSD Electric Racing"
    When I click "click here to resubscribe!"
    Then I should see "We just subscribed Alice Neilson to UCSD Electric Racing"
