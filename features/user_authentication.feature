Feature: User Registration and Login
  As a Columbia University student
  I want to create an account and log in
  So that I can use the FoundIt platform

  Background:
    Given I am on the home page

  Scenario: Successful registration
    When I click "Sign Up"
    And I fill in "Email" with "new.student@columbia.edu"
    And I fill in "First Name" with "New"
    And I fill in "Last Name" with "Student"
    And I fill in "UNI" with "ns1234"
    And I fill in "Password" with "password123"
    And I fill in "Password Confirmation" with "password123"
    And I click "Create Account"
    Then I should be on the dashboard page
    And I should see "Welcome back, New Student"

  Scenario: User login
    Given I have a student account
    When I click "Log In"
    And I fill in "Email" with "student@columbia.edu"
    And I fill in "Password" with "password123"
    And I click "Log In"
    Then I should be on the dashboard page
    And I should see "Welcome back, Student User"

  Scenario: Invalid login
    Given I have a student account
    When I click "Log In"
    And I fill in "Email" with "student@columbia.edu"
    And I fill in "Password" with "wrongpassword"
    And I click "Log In"
    Then I should see "Invalid email or password"
