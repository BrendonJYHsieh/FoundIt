Feature: Dashboard and User Experience
  As a logged-in user
  I want to see my dashboard with relevant information
  So that I can manage my lost and found items effectively

  Background:
    Given I am logged in as "john.doe@columbia.edu"

  Scenario: View Dashboard Overview
    Given I have posted 2 lost items and 1 found item
    And I have 3 pending matches
    When I visit the dashboard
    Then I should see my reputation score
    And I should see "2" lost items
    And I should see "1" found items
    And I should see "3" pending matches
    And I should see "0" items recovered

  Scenario: View Recent Activity
    Given I have recent activity:
      | Type | Description | Date |
      | Lost Item | Posted lost phone | Today |
      | Found Item | Posted found laptop | Yesterday |
      | Match | New match found (85%) | Today |
    When I visit the dashboard
    Then I should see the recent activity in chronological order
    And I should see "Posted lost phone" from today
    And I should see "Posted found laptop" from yesterday
    And I should see "New match found (85%)" from today

  Scenario: Quick Actions
    Given I am on the dashboard
    When I click "Post Lost Item"
    Then I should be redirected to the new lost item page
    When I go back to the dashboard
    And I click "Post Found Item"
    Then I should be redirected to the new found item page

  Scenario: Reputation System
    Given I have a reputation score of 5
    When I visit the dashboard
    Then I should see "5" as my reputation score
    And I should see "Community Member" badge
    When my reputation score reaches 10
    And I visit the dashboard
    Then I should see "10" as my reputation score
    And I should see "Good Samaritan" badge

  Scenario: Navigation Links
    Given I am on the dashboard
    When I click "My Profile"
    Then I should be redirected to my profile page
    When I go back to the dashboard
    And I click "Logout"
    Then I should be redirected to the home page
    And I should see "Successfully logged out!"

  Scenario: Empty State
    Given I have no lost items, found items, or matches
    When I visit the dashboard
    Then I should see "No lost items yet"
    And I should see "No found items yet"
    And I should see "No pending matches"
    And I should see links to post my first items
