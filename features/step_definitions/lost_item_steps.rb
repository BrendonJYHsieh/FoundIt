# features/step_definitions/lost_item_steps.rb

Given("I am on the new lost item page") do
  visit new_lost_item_path
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end

When("I fill in verification questions with:") do |table|
  questions = table.hashes.map { |row| { "question" => row["Question"], "answer" => row["Answer"] } }
  fill_in "Verification Questions", with: questions.to_json
end

When("I click lost item button {string}") do |button|
  click_button button
end

Then("I should be redirected to the lost item show page") do
  expect(current_path).to match(/\/lost_items\/\d+/)
end

Given("I have posted a lost item {string}") do |item_type|
  @lost_item = @user.lost_items.create!(
    item_type: "phone", # Use a valid item type
    description: "Test #{item_type} description",
    location: "Butler Library",
    lost_date: 1.day.ago,
    verification_questions: '[{"question": "What color is it?", "answer": "Blue"}]',
    status: "active"
  )
end

Given("there is a found item {string} with {int}% similarity") do |item_type, similarity|
  finder = User.create!(
    email: "finder@columbia.edu",
    uni: "fd1234",
    password: "password123",
    password_confirmation: "password123",
    verified: true
  )
  
  @found_item = finder.found_items.create!(
    item_type: item_type.downcase,
    description: "Test #{item_type} description",
    location: "Butler Library",
    found_date: 1.day.ago,
    status: "active"
  )
  
  @match = Match.create!(
    lost_item: @lost_item,
    found_item: @found_item,
    similarity_score: similarity / 100.0,
    status: "pending"
  )
end

When("I visit the lost item show page") do
  visit lost_item_path(@lost_item)
end

Then("I should see {string} match") do |percentage|
  expect(page).to have_content("#{percentage}% match")
end

Then("I should see the found item details") do
  expect(page).to have_content(@found_item.description)
end

When("I visit my lost items index page") do
  visit lost_items_path
end

Then("I should see {string} in the list") do |item_type|
  expect(page).to have_content(item_type)
end

When("I click lost item link {string}") do |action|
  click_link action
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Then("the item status should be {string}") do |status|
  expect(@lost_item.reload.status).to eq(status)
end

When("I visit the lost item edit page") do
  visit edit_lost_item_path(@lost_item)
end

When("I change {string} to {string}") do |field, value|
  fill_in field, with: value
end

When("I click lost item update button {string}") do |button|
  click_button button
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

When("I click lost item action {string}") do |action|
  click_link action
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Then("the item should not appear in the list") do
  expect(page).not_to have_content(@lost_item.item_type.capitalize)
end

Given("another user has posted a lost item {string}") do |item_type|
  @other_user = User.create!(
    email: "other@columbia.edu",
    uni: "ot1234",
    first_name: "Other",
    last_name: "User",
    password: "password123",
    password_confirmation: "password123",
    verified: true
  )
  
  @other_lost_item = @other_user.lost_items.create!(
    item_type: "phone", # Use a valid item type
    description: "Test #{item_type} description",
    location: "Butler Library",
    lost_date: 1.day.ago,
    status: "active"
  )
end

Given("I have posted a lost item {string} at {string}") do |item_type, location|
  @lost_item = @user.lost_items.create!(
    item_type: "phone", # Use a valid item type
    description: "Test #{item_type} description",
    location: location,
    lost_date: 1.day.ago,
    status: "active"
  )
end

When("I visit the lost items feed") do
  visit feed_lost_items_path
end

When("I visit the all lost items page") do
  visit all_lost_items_path
end

When("I fill in lost item {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I try to edit the lost item") do
  visit edit_lost_item_path(@other_lost_item)
end

Then("I should be redirected to the lost item show page") do
  expect(current_path).to match(/\/lost_items\/\d+/)
end

Then("I should remain on the new lost item page") do
  expect(current_path).to eq(new_lost_item_path)
end

Given("I am on the new lost item page on mobile") do
  # Skip mobile testing for now as it requires a different driver
  visit new_lost_item_path
end

When("I click lost item mobile {string}") do |action|
  click_link action
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Then("the item status should be {string}") do |status|
  expect(@lost_item.reload.status).to eq(status)
end

When("I visit the lost item edit page") do
  visit edit_lost_item_path(@lost_item)
end

When("I change {string} to {string}") do |field, value|
  fill_in field, with: value
end

Then("the item should not appear in the list") do
  expect(page).not_to have_content(@lost_item.item_type.capitalize)
end
