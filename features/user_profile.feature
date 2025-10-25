Feature: User Profile Management
  As a Columbia University student
  I want to manage my profile and view other users
  So that I can build trust and connect with the community

  Background:
    Given I am logged in as "student@columbia.edu"

  Scenario: View my profile
    When I visit the profile page
    Then I should see "Student User"
    And I should see "student@columbia.edu"
    And I should see "STU1234"

  Scenario: Update my profile
    When I visit the profile page
    And I click "Edit Profile"
    And I fill in "Bio" with "Computer Science student"
    And I fill in "Phone" with "555-123-4567"
    And I click "Update Profile"
    Then I should see "Profile updated successfully"
    And I should see "Computer Science student"

  Scenario: View profile completion
    When I visit the profile page
    Then I should see "Profile Completion"
    And I should see "Complete your profile"

  Scenario: View reputation score
    When I visit the profile page
    Then I should see "Reputation Score"
    And I should see "Community Member"
