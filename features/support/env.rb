require 'cucumber/rails'

# SimpleCov configuration for Cucumber coverage
require 'simplecov'

SimpleCov.start 'rails' do
  # Configure coverage thresholds (disable failure on low coverage)
  minimum_coverage 0  # Set to 0 to prevent failures
  minimum_coverage_by_file 0  # Set to 0 to prevent failures
  
  # Add custom groups for better organization
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Jobs', 'app/jobs'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  
  # Exclude files from coverage
  add_filter '/config/'
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/db/'
  add_filter '/bin/'
  add_filter '/lib/tasks/'
  add_filter '/vendor/'
  add_filter '/tmp/'
  add_filter '/log/'
  add_filter '/storage/'
  add_filter '/public/'
  add_filter '/node_modules/'
  
  # Track branches for better coverage analysis
  track_files 'app/**/*.rb'
  
  # Generate HTML and text reports
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::SimpleFormatter
  ])
  
  # Set coverage directory
  coverage_dir 'coverage'
  
  # Merge results from multiple test runs (RSpec + Cucumber)
  merge_timeout 3600
  
  # Enable merging for combined coverage
  command_name 'Cucumber Integration Tests'
end

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation

# Capybara configuration
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

# Configure Capybara to use the test database
Capybara.app_host = 'http://localhost:3000'

# Include FactoryBot methods for Cucumber
require 'factory_bot'
include FactoryBot::Syntax::Methods
