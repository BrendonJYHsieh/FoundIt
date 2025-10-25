Feature: Found Item Management
  As a Columbia University student
  I want to report and manage found items
  So that I can help reunite lost items with their owners

  Background:
    Given I am logged in as "student@columbia.edu"

  Scenario: Report a found item
    When I click "Post Found Item"
    And I select "phone" from "Item Type"
    And I fill in "Description" with "Black iPhone with clear case"
    And I fill in "Location" with "Butler Library"
    And I fill in "Found Date" with "2024-01-15"
    And I click "Submit Found Item"
    Then I should be on the dashboard page
    And I should see "Found item posted successfully"

  Scenario: View my found items
    Given I have posted a phone item
    When I visit the found items page
    Then I should see "Black iPhone with clear case"
    And I should see "Butler Library"

  Scenario: Mark item as returned
    Given I have posted a phone item
    When I visit the found items page
    And I click "Mark as Returned"
    Then I should see "Item marked as returned"
    And the item status should be "returned"

  Scenario: View all found items
    Given someone has posted a phone item
    When I visit the found items page
    Then I should see "Black iPhone with clear case"
    And I should see "Other User"
