# frozen_string_literal: true

# --------------------------------------------------
# Authentication
# --------------------------------------------------
Given('I log in as {string}') do |email|
  uni = email.split('@').first

  @user = User.find_or_create_by!(email: email) do |u|
    u.password = 'password'
    u.uni = uni
    u.verified = true if u.respond_to?(:verified)
  end

  visit login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: 'password'
  click_button 'Log In'
end

# --------------------------------------------------
# Create a Found Item
# --------------------------------------------------
Given('I am on the new found item page') do
  visit new_found_item_path
end

When('I select {string} option from {string}') do |value, field|
  select value, from: field
end

When('I fill in {string} field with {string}') do |field, value|
  fill_in field, with: value
end

When('I optionally add a photo URL for the found item') do
  fill_in 'Photo URLs (optional)', with: 'https://example.com/photo.jpg'
end

When('I click on {string}') do |button_text|
  click_button button_text
end

Then('I should be redirected to the found item show page') do
  expect(page.current_path).to match(%r{/found_items/\d+})
end

Then('I should see {string} on the screen') do |text|
  expect(page).to have_content(text)
end

Then('I should see the found item details on the page') do
  expect(page).to have_content('Item Type')
  expect(page).to have_content('Description')
  expect(page).to have_content('Location Found')
  expect(page).to have_content('Date Found')
end

# --------------------------------------------------
# View All Found Items
# --------------------------------------------------
Given('a found item with photos exists') do
  user = @user || User.create!(email: 'ss2222@columbia.edu', password: 'password')
  @found_item = FoundItem.create!(
    user: user,
    item_type: 'wallet',
    description: 'Black wallet',
    location: 'Low Library',
    found_date: Date.today,
    status: 'active',
    photos: ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'].to_json
  )
end

When('I visit the found items index page') do
  visit found_items_path
end

Then('I should see the list of found items') do
  expect(page).to have_css('.found-card')
  expect(page).to have_content('My Found Items')
end

Then('I should see each found item’s type, location, date, and status') do
  expect(page).to have_content('Wallet')
  expect(page).to have_content('Low Library')
  expect(page).to have_content('Active')
end

Then("I should see the found item's photos displayed on the page") do
  JSON.parse(@found_item.photos).each do |url|
    expect(page).to have_css("img[src='#{url}']")
  end
end

# --------------------------------------------------
# Manage Found Item Posts
# --------------------------------------------------
Given('I have posted a found item {string}') do |item_name|
  @found_item = (@user || User.first).found_items.create!(
    item_type: 'phone',
    description: item_name,
    location: 'Butler Library',
    found_date: Date.today,
    status: 'active'
  )
end

When('I visit my found items index page') do
  visit found_items_path
end

Then('I should see {string} on the found items list') do |item_name|
  expect(page).to have_content(item_name)
end

When('I click on the {string} item link') do |item_name|
  click_link item_name
end

Then("the found item's status should be {string}") do |expected_status|
  @found_item.reload
  expect(@found_item.status.downcase).to eq(expected_status.downcase)
end

Then('my reputation score should increase by {int}') do |points|
  expect(@user.reload.reputation_score).to be >= points
end

# --------------------------------------------------
# View Found Item Status
# --------------------------------------------------
When('I visit the found item show page') do
  visit found_item_path(@found_item)
end

Then('I should see the found item details') do
  expect(page).to have_content(@found_item.description)
  expect(page).to have_content(@found_item.location)
end

Then('I should see "Active" status for the found item') do
  expect(page).to have_content('Active')
end

# --------------------------------------------------
# Negative: Buttons Hidden for Returned/Closed
# --------------------------------------------------
Given('I have a found item {string} with status {string}') do |item_name, status|
  @found_item = (@user || User.first).found_items.create!(
    item_type: 'phone',
    description: item_name,
    location: 'Butler Library',
    found_date: Date.today - 2.days,
    status: status
  )
end

Then('I should not see the {string} button') do |button_text|
  expect(page).not_to have_button(button_text)
end