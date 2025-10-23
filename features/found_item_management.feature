Feature: Found Item Management
  As a student who found something
  I want to post details about the found item
  So that I can help return it to its owner

  Background:
    Given I log in as "ss1111@columbia.edu"

  Scenario: Post Found Item Successfully
    Given I am on the new found item page
    When I select "phone" option from "Item Type"
    And I fill in "Description" field with "iPhone 13 Pro with blue case, found near Butler Library"
    And I fill in "Location" field with "Butler Library"
    And I fill in "Date Found" field with "2024-01-15"
    And I optionally add a photo URL for the found item
    And I click on "Submit Found Item"
    Then I should be redirected to the found item show page
    And I should see "Your found item has been posted." on the screen
    And I should see the found item details on the page

  Scenario: View Photos on Show Page
    Given a found item with photos exists
    When I visit the found items index page
    Then I should see the list of found items
    And I should see each found item’s type, location, date, and status
    When I click on the "Black wallet" item link
    Then I should see the found item's photos displayed on the page

  Scenario: Manage Found Item Posts From Index Page
    Given I have posted a found item "iPhone 13 Pro"
    When I visit my found items index page
    Then I should see "iPhone 13 Pro" on the found items list
    When I click on the "iPhone 13 Pro" item link
    And I click on "Mark as Returned"
    Then I should see "🎉 Item marked as returned! Reputation +5." on the screen
    And the found item's status should be "returned"
    And my reputation score should increase by 5

  Scenario: Close Found Item Post From Index Page
    Given I have posted a found item "iPhone 13 Pro"
    When I visit my found items index page
    Then I should see "iPhone 13 Pro" on the found items list
    When I click on the "iPhone 13 Pro" item link
    And I click on "Close Listing"
    Then I should see "📦 Listing closed successfully." on the screen
    And the found item's status should be "closed"

  Scenario: View Found Item Status
    Given I have posted a found item "iPhone 13 Pro"
    When I visit the found item show page
    Then I should see the found item details on the page
    And I should see "Active" status for the found item

  Scenario: Close Found Item Post
    Given I have posted a found item "iPhone 13 Pro"
    When I visit the found item show page
    And I click on "Close Listing"
    Then I should see "📦 Listing closed successfully." on the screen
    And the found item's status should be "closed"

  Scenario: Manage Found Item Posts
    Given I have posted a found item "iPhone 13 Pro"
    When I visit the found item show page
    And I click on "Mark as Returned"
    Then I should see "🎉 Item marked as returned! Reputation +5." on the screen
    And the found item's status should be "returned"
    And my reputation score should increase by 5

  Scenario: Do not show Mark as Returned or Close Listing for returned items
    Given I have a found item "iPhone 13 Pro" with status "returned"
    When I visit my found items index page
    Then I should see "iPhone 13 Pro" on the found items list
    When I click on the "iPhone 13 Pro" item link
    Then I should not see the "Mark as Returned" button
    And I should not see the "Close Listing" button

  Scenario: Do not show Mark as Returned or Close Listing for closed items
    Given I have a found item "MacBook Air" with status "closed"
    When I visit my found items index page
    Then I should see "MacBook Air" on the found items list
    When I click on the "MacBook Air" item link
    Then I should not see the "Mark as Returned" button
    And I should not see the "Close Listing" button
