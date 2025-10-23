Feature: Lost Item Management
  As a student who lost something
  I want to post details about my lost item
  So that the system can help me find it

  Background:
    Given I am logged in as "john.doe@columbia.edu"

  Scenario: Post Lost Item Successfully
    Given I am on the new lost item page
    When I select "phone" from "Item Type"
    And I fill in lost item "Description" with "iPhone 13 Pro with blue case, lost near Butler Library"
    And I fill in lost item "Location" with "Butler Library"
    And I fill in lost item "Date Lost" with "2024-01-15"
    And I click lost item "Submit Lost Item"
    Then I should be redirected to the lost item show page
    And I should see lost item "Lost item posted successfully!"

  Scenario: Manage Lost Item Posts
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit my lost items index page
    Then I should see lost item content "iPhone 13 Pro" in the list
    When I visit the lost item show page
    And I click lost item "Mark as Found"
    Then I should see lost item "Item marked as found!"
    And the item status should be "found"

  Scenario: Edit Lost Item Details
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit the lost item edit page
    And I change "Description" to "iPhone 13 Pro with blue case, lost near Butler Library entrance"
    And I click lost item "Update Lost Item"
    Then I should see lost item "Lost item updated successfully!"

  Scenario: Delete Lost Item Post
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit my lost items index page
    And I visit the lost item show page
    And I click lost item "Close Listing"
    Then I should see lost item "Lost item post closed!"
    And the item status should be "closed"

  Scenario: View All Lost Items Feed
    Given I have posted a lost item "iPhone 13 Pro"
    And another user has posted a lost item "MacBook Pro"
    When I visit the lost items feed
    Then I should see lost item content "iPhone 13 Pro"
    And I should see lost item content "MacBook Pro"

  Scenario: Create Lost Item with Photos
    Given I am on the new lost item page
    When I select "phone" from "Item Type"
    And I fill in lost item "Description" with "iPhone 13 Pro with photos"
    And I fill in lost item "Location" with "Butler Library"
    And I fill in lost item "Date Lost" with "2024-01-15"
    And I fill in lost item "Photo URLs (optional)" with "photo1.jpg, photo2.jpg"
    And I click lost item "Submit Lost Item"
    Then I should be redirected to the lost item show page
    And I should see lost item "Lost item posted successfully!"


  Scenario: Access Lost Item Without Permission
    Given another user has posted a lost item "iPhone 13 Pro"
    When I try to edit the lost item
    Then I should see lost item content "You can only edit your own lost items."
    And I should be redirected to the lost item show page

  Scenario: View All Lost Items
    Given I have posted a lost item "iPhone 13 Pro"
    And another user has posted a lost item "MacBook Pro"
    When I visit the all lost items page
    Then I should see lost item content "iPhone 13 Pro"
    And I should see lost item content "MacBook Pro"

  Scenario: Mobile Responsive Lost Item Creation
    Given I am on the new lost item page on mobile
    When I select "phone" from "Item Type"
    And I fill in lost item "Description" with "iPhone 13 Pro mobile test"
    And I fill in lost item "Location" with "Butler Library"
    And I fill in lost item "Date Lost" with "2024-01-15"
    And I click lost item "Submit Lost Item"
    Then I should be redirected to the lost item show page
    And I should see lost item "Lost item posted successfully!"

  Scenario: View Lost Item Details
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit the lost item show page
    Then I should see lost item content "Phone"
    And I should see lost item content "Test iPhone 13 Pro description"
    And I should see lost item content "Butler Library"
    And I should see lost item content "Active"

  Scenario: Navigate Back to Dashboard
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit the lost item show page
    And I click lost item "← Back to Dashboard"
    Then I should be redirected to the dashboard

  Scenario: View Lost Item with No Photos
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit the lost item show page
    Then I should see lost item content "Phone"
    And I should not see "Photos:"

  Scenario: View Lost Item with Photos
    Given I am on the new lost item page
    When I select "phone" from "Item Type"
    And I fill in lost item "Description" with "iPhone 13 Pro with photos"
    And I fill in lost item "Location" with "Butler Library"
    And I fill in lost item "Date Lost" with "2024-01-15"
    And I fill in lost item "Photo URLs (optional)" with "https://example.com/photo1.jpg,https://example.com/photo2.jpg"
    And I click lost item "Submit Lost Item"
    Then I should be redirected to the lost item show page
    And I should see lost item "Lost item posted successfully!"
    And I should see lost item content "Photos:"

  Scenario: Edit Lost Item with Different Item Type
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit the lost item edit page
    And I select "laptop" from "Item Type"
    And I change "Description" to "MacBook Pro 13-inch"
    And I click lost item "Update Lost Item"
    Then I should see lost item "Lost item updated successfully!"
    And I should be redirected to the lost item show page
    And I should see lost item content "Laptop"

  Scenario: Access Lost Item Show Page
    Given I have posted a lost item "iPhone 13 Pro"
    When I visit the lost item show page
    Then I should see lost item content "Phone Lost"
    And I should see lost item content "Test iPhone 13 Pro description"
    And I should see lost item content "Butler Library"
    And I should see lost item content "john.doe@columbia.edu"
