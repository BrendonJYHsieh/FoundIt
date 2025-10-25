require 'cucumber/rails'

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
