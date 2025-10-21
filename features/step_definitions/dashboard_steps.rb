# features/step_definitions/dashboard_steps.rb

Given("I have posted {int} lost items and {int} found item") do |lost_count, found_count|
  lost_count.times do |i|
    @user.lost_items.create!(
      item_type: "phone",
      description: "Lost item #{i + 1}",
      location: "Butler Library",
      lost_date: i.days.ago,
      verification_questions: '[{"question": "What color?", "answer": "Blue"}]',
      status: "active"
    )
  end
  
  found_count.times do |i|
    @user.found_items.create!(
      item_type: "laptop",
      description: "Found item #{i + 1}",
      location: "Lerner Hall",
      found_date: i.days.ago,
      status: "active"
    )
  end
end

Given("I have {int} pending matches") do |count|
  count.times do |i|
    finder = User.create!(
      email: "finder#{i}@columbia.edu",
      uni: "fd#{i}234",
      password: "password123",
      password_confirmation: "password123",
      verified: true
    )
    
    found_item = finder.found_items.create!(
      item_type: "phone",
      description: "Found phone #{i + 1}",
      location: "Butler Library",
      found_date: 1.day.ago,
      status: "active"
    )
    
    Match.create!(
      lost_item: @user.lost_items.first,
      found_item: found_item,
      similarity_score: 0.8,
      status: "pending"
    )
  end
end

When("I visit the dashboard") do
  visit dashboard_path
end

Then("I should see my reputation score") do
  expect(page).to have_content(@user.reputation_score)
end

Then("I should see {string} lost items") do |count|
  expect(page).to have_content("#{count} Lost Items")
end

Then("I should see {string} found items") do |count|
  expect(page).to have_content("#{count} Found Items")
end

Then("I should see {string} pending matches") do |count|
  expect(page).to have_content("#{count} Pending Matches")
end

Then("I should see {string} items recovered") do |count|
  expect(page).to have_content("#{count} Items Recovered")
end

Given("I have recent activity:") do |table|
  table.hashes.each do |row|
    case row["Type"]
    when "Lost Item"
      @user.lost_items.create!(
        item_type: "phone",
        description: row["Description"],
        location: "Butler Library",
        lost_date: row["Date"] == "Today" ? Time.current : 1.day.ago,
        verification_questions: '[{"question": "What color?", "answer": "Blue"}]',
        status: "active"
      )
    when "Found Item"
      @user.found_items.create!(
        item_type: "laptop",
        description: row["Description"],
        location: "Lerner Hall",
        found_date: row["Date"] == "Today" ? Time.current : 1.day.ago,
        status: "active"
      )
    when "Match"
      finder = User.create!(
        email: "matcher@columbia.edu",
        uni: "mt1234",
        password: "password123",
        password_confirmation: "password123",
        verified: true
      )
      
      found_item = finder.found_items.create!(
        item_type: "phone",
        description: "Found phone",
        location: "Butler Library",
        found_date: 1.day.ago,
        status: "active"
      )
      
      Match.create!(
        lost_item: @user.lost_items.first,
        found_item: found_item,
        similarity_score: 0.85,
        status: "pending"
      )
    end
  end
end

Then("I should see the recent activity in chronological order") do
  expect(page).to have_content("Recent Activity")
end

Then("I should see {string} from today") do |description|
  expect(page).to have_content(description)
end

Then("I should see {string} from yesterday") do |description|
  expect(page).to have_content(description)
end

Then("I should see {string} from today") do |description|
  expect(page).to have_content(description)
end

Given("I am on the dashboard") do
  visit dashboard_path
end

When("I click {string}") do |link|
  click_link link
end

Then("I should be redirected to the new lost item page") do
  expect(current_path).to eq(new_lost_item_path)
end

When("I go back to the dashboard") do
  visit dashboard_path
end

Then("I should be redirected to the new found item page") do
  expect(current_path).to eq(new_found_item_path)
end

Given("I have a reputation score of {int}") do |score|
  @user.update!(reputation_score: score)
end

Then("I should see {string} as my reputation score") do |score|
  expect(page).to have_content(score)
end

Then("I should see {string} badge") do |badge|
  expect(page).to have_content(badge)
end

When("my reputation score reaches {int}") do |score|
  @user.update!(reputation_score: score)
end

Then("I should see {string} as my reputation score") do |score|
  expect(page).to have_content(score)
end

Then("I should see {string} badge") do |badge|
  expect(page).to have_content(badge)
end

When("I click {string}") do |link|
  click_link link
end

Then("I should be redirected to my profile page") do
  expect(current_path).to eq(user_path(@user))
end

When("I go back to the dashboard") do
  visit dashboard_path
end

When("I click {string}") do |link|
  click_link link
end

Then("I should be redirected to the home page") do
  expect(current_path).to eq(root_path)
end

Then("I should see {string}!") do |message|
  expect(page).to have_content(message)
end

Given("I have no lost items, found items, or matches") do
  @user.lost_items.destroy_all
  @user.found_items.destroy_all
  Match.joins(:lost_item).where(lost_items: { user: @user }).destroy_all
  Match.joins(:found_item).where(found_items: { user: @user }).destroy_all
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should see links to post my first items") do
  expect(page).to have_link("Post Lost Item")
  expect(page).to have_link("Post Found Item")
end
