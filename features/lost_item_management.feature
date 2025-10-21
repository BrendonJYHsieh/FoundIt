Feature: Lost Item Management
  As a student who lost something
  I want to post details about my lost item
  So that the system can help me find it

  Background:
    Given I am logged in as "john.doe@columbia.edu"

  Scenario: Post Lost Item Successfully
    Given I am on the new lost item page
    When I select "phone" from "Item Type"
    And I fill in "Description" with "iPhone 13 Pro with blue case, lost near Butler Library"
    And I fill in "Location" with "Butler Library"
    And I fill in "Lost Date" with "2024-01-15"
    And I fill in verification questions with:
      | Question | Answer |
      | What color is the phone case? | Blue |
      | What sticker is on the back? | Columbia University |
    And I click "Create Lost Item"
    Then I should be redirected to the lost item show page
    And I should see "Lost item posted successfully!"

  Scenario: View Lost Item Matches
    Given I have posted a lost item "iPhone 13 Pro"
    And there is a found item "iPhone 13 Pro" with 85% similarity
    When I visit the lost item show page
    Then I should see "85% match"
    And I should see the found item details

  Scenario: Manage Lost Item Posts
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit my lost items index page
    Then I should see "iPhone 13 Pro" in the list
    When I click "Mark as Found"
    Then I should see "Item marked as found!"
    And the item status should be "found"

  Scenario: Edit Lost Item Details
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit the lost item edit page
    And I change "Description" to "iPhone 13 Pro with blue case, lost near Butler Library entrance"
    And I click "Update Lost Item"
    Then I should see "Lost item updated successfully!"

  Scenario: Delete Lost Item Post
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit my lost items index page
    And I click "Delete"
    Then I should see "Lost item deleted successfully!"
    And the item should not appear in the list
