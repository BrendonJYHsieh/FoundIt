# features/step_definitions/user_steps.rb

Given("the application is running") do
  # Application is already running
end

Given("I am on the signup page") do
  visit signup_path
end

Given("I am on the login page") do
  visit login_path
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I click {string}") do |button|
  click_button button
end

Then("I should be redirected to the dashboard") do
  expect(current_path).to eq(dashboard_path)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Given("I have an account with email {string} and password {string}") do |email, password|
  @user = User.create!(
    email: email,
    uni: "jd4122",
    password: password,
    password_confirmation: password,
    verified: true
  )
end

Given("I am logged in as {string}") do |email|
  @user = User.find_by(email: email) || User.create!(
    email: email,
    uni: email.split('@').first + "1234",
    password: "password123",
    password_confirmation: "password123",
    verified: true
  )
  visit login_path
  fill_in "Email", with: email
  fill_in "Password", with: "password123"
  click_button "Log In"
end

When("I click {string}") do |link|
  click_link link
end

Then("I should be redirected to the home page") do
  expect(current_path).to eq(root_path)
end
