# features/step_definitions/found_item_steps.rb

Given("I am on the new found item page") do
  visit new_found_item_path
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end

When("I upload a photo of the item") do
  # For MVP, we'll simulate photo upload
  # In a real implementation, this would use file upload
end

When("I click {string}") do |button|
  click_button button
end

Then("I should be redirected to the found item show page") do
  expect(current_path).to match(/\/found_items\/\d+/)
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Given("I have posted a found item {string}") do |item_type|
  @found_item = @user.found_items.create!(
    item_type: item_type.downcase,
    description: "Test #{item_type} description",
    location: "Butler Library",
    found_date: 1.day.ago,
    status: "active"
  )
end

Given("there is a lost item {string} with verification questions") do |item_type|
  loser = User.create!(
    email: "loser@columbia.edu",
    uni: "ls1234",
    password: "password123",
    password_confirmation: "password123",
    verified: true
  )
  
  @lost_item = loser.lost_items.create!(
    item_type: item_type.downcase,
    description: "Test #{item_type} description",
    location: "Butler Library",
    lost_date: 1.day.ago,
    verification_questions: '[{"question": "What color is it?", "answer": "Blue"}]',
    status: "active"
  )
end

When("I receive a match notification") do
  @match = Match.create!(
    lost_item: @lost_item,
    found_item: @found_item,
    similarity_score: 0.85,
    status: "pending"
  )
end

When("I visit the match verification page") do
  visit match_path(@match)
end

When("I answer the verification questions correctly") do
  answers = { "0" => "Blue" }
  fill_in "Answer 0", with: "Blue"
  click_button "Submit Answers"
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Then("I should be able to contact the owner") do
  expect(@match.reload.status).to eq("verified")
end

When("I visit my found items index page") do
  visit found_items_path
end

Then("I should see {string} in the list") do |item_type|
  expect(page).to have_content(item_type)
end

When("I click {string}") do |action|
  click_link action
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Then("the item status should be {string}") do |status|
  expect(@found_item.reload.status).to eq(status)
end

Then("my reputation score should increase by {int}") do |points|
  expect(@user.reload.reputation_score).to eq(points)
end

When("I visit the found item show page") do
  visit found_item_path(@found_item)
end

Then("I should see the item details") do
  expect(page).to have_content(@found_item.description)
end

Then("I should see {string} status") do |status|
  expect(page).to have_content(status)
end

Then("I should see any pending matches") do
  expect(page).to have_content("Matches")
end

When("I click {string}") do |action|
  click_link action
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Then("the item status should be {string}") do |status|
  expect(@found_item.reload.status).to eq(status)
end
