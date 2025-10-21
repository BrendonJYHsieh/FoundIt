Feature: Found Item Management
  As a student who found something
  I want to post details about the found item
  So that I can help return it to its owner

  Background:
    Given I am logged in as "jane.smith@columbia.edu"

  Scenario: Post Found Item Successfully
    Given I am on the new found item page
    When I select "phone" from "Item Type"
    And I fill in "Description" with "iPhone 13 Pro with blue case, found near Butler Library"
    And I fill in "Location" with "Butler Library"
    And I fill in "Found Date" with "2024-01-15"
    And I upload a photo of the item
    And I click "Create Found Item"
    Then I should be redirected to the found item show page
    And I should see "Found item posted successfully!"

  Scenario: Respond to Verification Questions
    Given I have posted a found item "iPhone 13 Pro"
    And there is a lost item "iPhone 13 Pro" with verification questions
    When I receive a match notification
    And I visit the match verification page
    And I answer the verification questions correctly
    Then I should see "Verification successful!"
    And I should be able to contact the owner

  Scenario: Manage Found Item Posts
    Given I have posted a found item "iPhone 13 Pro"
    When I visit my found items index page
    Then I should see "iPhone 13 Pro" in the list
    When I click "Mark as Returned"
    Then I should see "Item marked as returned!"
    And the item status should be "returned"
    And my reputation score should increase by 5

  Scenario: View Found Item Status
    Given I have posted a found item "iPhone 13 Pro"
    When I visit the found item show page
    Then I should see the item details
    And I should see "Active" status
    And I should see any pending matches

  Scenario: Close Found Item Post
    Given I have posted a found item "iPhone 13 Pro"
    When I visit the found item show page
    And I click "Close Post"
    Then I should see "Found item post closed!"
    And the item status should be "closed"
