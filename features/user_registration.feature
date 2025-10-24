Feature: User Registration and Authentication
  As a Columbia University student
  I want to register and log into FoundIt
  So that I can access the trusted student-only network

  Background:
    Given the application is running

  Scenario: Student Registration with Valid Columbia Email
    Given I am on the signup page
    When I fill in "Email" with "john.doe@columbia.edu"
    And I fill in "First Name" with "John"
    And I fill in "Last Name" with "Doe"
    And I fill in "UNI" with "jd4122"
    And I fill in "Password" with "securepassword123"
    And I fill in "Confirm Password" with "securepassword123"
    And I click "Create Account"
    Then I should be redirected to the dashboard
    And I should see "Account created successfully!"

  Scenario: Registration with Invalid Email
    Given I am on the signup page
    When I fill in "Email" with "john.doe@gmail.com"
    And I fill in "First Name" with "John"
    And I fill in "Last Name" with "Doe"
    And I fill in "UNI" with "jd4122"
    And I fill in "Password" with "securepassword123"
    And I fill in "Confirm Password" with "securepassword123"
    And I click "Create Account"
    Then I should see "Email is invalid"

  Scenario: Registration with Invalid UNI Format
    Given I am on the signup page
    When I fill in "Email" with "john.doe@columbia.edu"
    And I fill in "First Name" with "John"
    And I fill in "Last Name" with "Doe"
    And I fill in "UNI" with "invalid123"
    And I fill in "Password" with "securepassword123"
    And I fill in "Confirm Password" with "securepassword123"
    And I click "Create Account"
    Then I should see "Uni is invalid"

  Scenario: User Login with Valid Credentials
    Given I have an account with email "john.doe@columbia.edu" and password "securepassword123"
    And I am on the login page
    When I fill in "Email" with "john.doe@columbia.edu"
    And I fill in "Password" with "securepassword123"
    And I click "Log In"
    Then I should be redirected to the dashboard
    And I should see "Successfully logged in!"

  Scenario: User Login with Invalid Credentials
    Given I am on the login page
    When I fill in "Email" with "john.doe@columbia.edu"
    And I fill in "Password" with "wrongpassword"
    And I click "Log In"
    Then I should see "Invalid email or password"

  Scenario: User Logout
    Given I am logged in as "john.doe@columbia.edu"
    When I click "Logout"
    Then I should be redirected to the home page
    And I should see "Successfully logged out!"
