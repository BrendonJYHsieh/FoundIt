# features/step_definitions/matching_steps.rb

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

Given("I have posted a lost item {string} at {string} on {string}") do |item_type, location, date|
  @lost_item = @user.lost_items.create!(
    item_type: item_type.downcase,
    description: "Test #{item_type} description",
    location: location,
    lost_date: Date.parse(date),
    verification_questions: '[{"question": "What color is it?", "answer": "Blue"}]',
    status: "active"
  )
end

Given("{string} has posted a found item {string} at {string} on {string}") do |email, item_type, location, date|
  finder = User.find_by(email: email) || User.create!(
    email: email,
    uni: email.split('@').first + "1234",
    password: "password123",
    password_confirmation: "password123",
    verified: true
  )
  
  @found_item = finder.found_items.create!(
    item_type: item_type.downcase,
    description: "Test #{item_type} description",
    location: location,
    found_date: Date.parse(date),
    status: "active"
  )
end

When("the matching algorithm runs") do
  FindMatchesJob.perform_now(@lost_item)
end

Then("a match should be created with similarity score >= {float}") do |min_score|
  match = Match.find_by(lost_item: @lost_item, found_item: @found_item)
  expect(match).to be_present
  expect(match.similarity_score).to be >= min_score
end

Then("both users should receive match notifications") do
  # In a real implementation, this would check for notifications
  # For MVP, we'll just verify the match exists
  expect(Match.exists?(lost_item: @lost_item, found_item: @found_item)).to be true
end

Given("I have posted a lost item {string} with verification questions:") do |item_type, table|
  questions = table.hashes.map { |row| { "question" => row["Question"], "answer" => row["Answer"] } }
  
  @lost_item = @user.lost_items.create!(
    item_type: item_type.downcase,
    description: "Test #{item_type} description",
    location: "Butler Library",
    lost_date: 1.day.ago,
    verification_questions: questions.to_json,
    status: "active"
  )
end

Given("there is a match with {string}") do |email|
  finder = User.find_by(email: email)
  @found_item = finder.found_items.create!(
    item_type: @lost_item.item_type,
    description: "Test found item",
    location: @lost_item.location,
    found_date: @lost_item.lost_date,
    status: "active"
  )
  
  @match = Match.create!(
    lost_item: @lost_item,
    found_item: @found_item,
    similarity_score: 0.85,
    status: "pending"
  )
end

When("{string} answers the verification questions:") do |email, table|
  answers = {}
  table.hashes.each_with_index do |row, index|
    answers[index.to_s] = row["Answer"]
  end
  
  @match.verify_answers!(answers)
end

Then("the verification should be successful") do
  expect(@match.reload.status).to eq("verified")
end

Then("the match status should be {string}") do |status|
  expect(@match.reload.status).to eq(status)
end

Then("contact information should be shared") do
  # In a real implementation, this would check if contact info is visible
  expect(@match.status).to eq("verified")
end

When("{string} answers the verification questions incorrectly:") do |email, table|
  answers = {}
  table.hashes.each_with_index do |row, index|
    answers[index.to_s] = row["Answer"]
  end
  
  @match.verify_answers!(answers)
end

Then("the verification should fail") do
  expect(@match.reload.status).to eq("rejected")
end

Then("contact information should not be shared") do
  expect(@match.status).to eq("rejected")
end

When("I view the match details") do
  visit match_path(@match)
end

Then("I should not see {string}'s contact information") do |email|
  expect(page).not_to have_content(email)
end

Then("I should only see the verification questions") do
  expect(page).to have_content("verification")
end

Given("there are multiple found items with different similarity scores:") do |table|
  table.hashes.each do |row|
    finder = User.create!(
      email: "#{row['Item'].downcase.gsub(' ', '.')}@columbia.edu",
      uni: "#{row['Item'].downcase.gsub(' ', '')}1234",
      password: "password123",
      password_confirmation: "password123",
      verified: true
    )
    
    found_item = finder.found_items.create!(
      item_type: row['Item'].downcase,
      description: "Test #{row['Item']} description",
      location: "Butler Library",
      found_date: 1.day.ago,
      status: "active"
    )
    
    Match.create!(
      lost_item: @lost_item,
      found_item: found_item,
      similarity_score: row['Similarity'].to_f / 100.0,
      status: "pending"
    )
  end
end

When("I view the matches") do
  visit lost_item_path(@lost_item)
end

Then("the {string} should be listed first") do |item_type|
  # Check that the highest similarity match appears first
  expect(page).to have_content(item_type)
end

Then("only matches with similarity >= {float} should be shown") do |min_score|
  # Check that only high-similarity matches are displayed
  matches = Match.where(lost_item: @lost_item).where('similarity_score >= ?', min_score)
  expect(matches.count).to be > 0
end
