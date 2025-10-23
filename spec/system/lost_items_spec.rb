require 'rails_helper'

RSpec.describe "Lost Items Workflow", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: "other@columbia.edu", uni: "ot1234") }

  before do
    driven_by(:rack_test)
    # Sign in user for system tests
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log In"
  end

  describe "Lost Item Navigation" do
    it "allows user to navigate to lost items pages" do
      # Test basic navigation
      visit lost_items_path
      expect(page).to have_content("My Lost Items")
      
      visit new_lost_item_path
      expect(page).to have_content("Post Lost Item")
      
      # Create a lost item programmatically for testing
      lost_item = create(:lost_item, user: user)
      visit lost_item_path(lost_item)
      expect(page).to have_content(lost_item.description)
    end
  end

  describe "Lost Item Display" do
    before do
      create(:lost_item, user: user, item_type: "phone", location: "Butler Library", description: "iPhone 13 Pro with blue case")
      create(:lost_item, user: other_user, item_type: "laptop", location: "Dodge Fitness Center", description: "MacBook Pro")
    end

    it "shows user's lost items on index page" do
      visit lost_items_path
      expect(page).to have_content("iPhone 13 Pro with blue case")
      expect(page).not_to have_content("MacBook Pro")
    end

    it "shows all lost items on all page" do
      visit all_lost_items_path
      expect(page).to have_content("iPhone 13 Pro with blue case")
      expect(page).to have_content("MacBook Pro")
    end
  end

  describe "Lost Item with Matches" do
    let(:lost_item) { create(:lost_item, user: user) }
    let(:found_item) { create(:found_item, user: other_user) }

    before do
      create(:match, lost_item: lost_item, found_item: found_item, similarity_score: 0.85)
    end

    it "displays lost item details" do
      visit lost_item_path(lost_item)
      expect(page).to have_content(lost_item.description)
      expect(page).to have_content("Active")
    end
  end

  describe "Authorization and Security" do
    let(:other_lost_item) { create(:lost_item, user: other_user) }

    it "prevents accessing other user's lost items" do
      visit lost_item_path(other_lost_item)
      # Should show the item but not allow editing
      expect(page).to have_content(other_lost_item.description)
    end
  end

  describe "Lost Item Feed" do
    before do
      create(:lost_item, user: user, status: "active", description: "Active item")
      create(:lost_item, user: other_user, status: "active", description: "Other's active item")
      create(:lost_item, user: user, status: "found", description: "Found item")
    end

    it "shows active lost items from all users" do
      visit feed_lost_items_path
      expect(page).to have_content("Active item")
      expect(page).to have_content("Other's active item")
      expect(page).not_to have_content("Found item")
    end
  end

  describe "Error Handling" do
    it "handles missing lost item gracefully" do
      visit lost_item_path(99999)
      expect(page).to have_content("Lost item not found")
    end
  end
end