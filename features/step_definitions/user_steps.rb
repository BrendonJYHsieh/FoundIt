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

When("I click button {string}") do |button|
  click_button button
end

When("I click link {string}") do |link|
  click_link link
end

Then("I should be redirected to the dashboard") do
  expect(current_path).to eq(dashboard_path)
end

Then("I should see {string}") do |text|
  # Handle specific text variations
  case text
  when "No found items yet"
    expect(page).to have_content("No active found items yet")
  else
    expect(page).to have_content(text)
  end
end

Given("I have an account with email {string} and password {string}") do |email, password|
  @user = User.create!(
    email: email,
    uni: "jd4122",
    first_name: "John",
    last_name: "Doe",
    password: password,
    password_confirmation: password,
    verified: true
  )
end

Given("I am logged in as {string}") do |email|
  email_prefix = email.split('@').first
  uni = "#{email_prefix[0..1].downcase}#{rand(1000..9999)}"
  
  @user = User.find_by(email: email) || User.create!(
    email: email,
    uni: uni,
    first_name: "John",
    last_name: "Doe",
    password: "password123",
    password_confirmation: "password123",
    verified: true
  )
  visit login_path
  fill_in "Email", with: email
  fill_in "Password", with: "password123"
  click_button "Log In"
end

Then("I should be redirected to the home page") do
  expect(current_path).to eq(root_path)
end
