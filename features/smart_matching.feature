Feature: Smart Matching and Verification
  As a user of the platform
  I want the system to intelligently match lost and found items
  So that reunions happen efficiently and securely

  Background:
    Given I am logged in as "john.doe@columbia.edu"
    And I am logged in as "jane.smith@columbia.edu"

  Scenario: Automatic Item Matching
    Given I have posted a lost item "iPhone 13 Pro" at "Butler Library" on "2024-01-15"
    And "jane.smith@columbia.edu" has posted a found item "iPhone 13 Pro" at "Butler Library" on "2024-01-15"
    When the matching algorithm runs
    Then a match should be created with similarity score >= 0.7
    And both users should receive match notifications

  Scenario: Verification System Success
    Given I have posted a lost item "iPhone 13 Pro" with verification questions:
      | Question | Answer |
      | What color is the phone case? | Blue |
      | What sticker is on the back? | Columbia University |
    And there is a match with "jane.smith@columbia.edu"
    When "jane.smith@columbia.edu" answers the verification questions:
      | Question | Answer |
      | What color is the phone case? | Blue |
      | What sticker is on the back? | Columbia University |
    Then the verification should be successful
    And the match status should be "verified"
    And contact information should be shared

  Scenario: Verification System Failure
    Given I have posted a lost item "iPhone 13 Pro" with verification questions:
      | Question | Answer |
      | What color is the phone case? | Blue |
      | What sticker is on the back? | Columbia University |
    And there is a match with "jane.smith@columbia.edu"
    When "jane.smith@columbia.edu" answers the verification questions incorrectly:
      | Question | Answer |
      | What color is the phone case? | Red |
      | What sticker is on the back? | NYU |
    Then the verification should fail
    And the match status should be "rejected"
    And contact information should not be shared

  Scenario: Privacy Protection
    Given I have posted a lost item "iPhone 13 Pro"
    And there is a match with "jane.smith@columbia.edu"
    When I view the match details
    Then I should not see "jane.smith@columbia.edu"'s contact information
    And I should only see the verification questions

  Scenario: High Similarity Match Priority
    Given I have posted a lost item "iPhone 13 Pro"
    And there are multiple found items with different similarity scores:
      | Item | Similarity |
      | iPhone 13 Pro | 0.95 |
      | iPhone 12 Pro | 0.75 |
      | Samsung Galaxy | 0.60 |
    When I view the matches
    Then the iPhone 13 Pro should be listed first
    And only matches with similarity >= 0.5 should be shown
