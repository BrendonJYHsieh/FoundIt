Feature: Lost Item Management
  As a Columbia University student
  I want to report and manage my lost items
  So that others can help me find them

  Background:
    Given I am logged in as "student@columbia.edu"

  Scenario: Report a lost item
    When I click "Post Lost Item"
    And I select "phone" from "Item Type"
    And I fill in "Description" with "Black iPhone with clear case"
    And I fill in "Location" with "Butler Library"
    And I fill in "Lost Date" with "2024-01-15"
    And I click "Submit Lost Item"
    Then I should be on the dashboard page
    And I should see "Lost item posted successfully"

  Scenario: View my lost items
    Given I have posted a phone item
    When I visit the lost items page
    Then I should see "Black iPhone with clear case"
    And I should see "Butler Library"

  Scenario: Edit my lost item
    Given I have posted a phone item
    When I visit the lost items page
    And I click "Edit"
    And I fill in "Description" with "Black iPhone with clear case and Columbia sticker"
    And I click "Update Lost Item"
    Then I should see "Lost item updated successfully"

  Scenario: Mark item as found
    Given I have posted a phone item
    When I visit the lost items page
    And I click "Mark as Found"
    Then I should see "Item marked as found"
    And the item status should be "found"
