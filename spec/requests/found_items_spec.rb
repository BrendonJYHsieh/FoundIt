require 'rails_helper'

RSpec.describe FoundItemsController, type: :controller do
  let(:user) { User.create!(email: "te1122@columbia.edu", password: "password", uni: "te1122") }
  let(:other_user) { User.create!(email: "op2322@columbia.edu", password: "password", uni: "op2322") }

  let!(:found_item) do
    user.found_items.create!(
      item_type: "phone",
      description: "Black iPhone found near Butler Library",
      location: "Butler Library",
      found_date: Date.today,
      status: "active",
      photos: ["https://example.com/photo1.jpg", "https://example.com/photo2.jpg"].to_json
    )
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  # ---------------------------------------------------------
  # INDEX – current user's own found items
  # ---------------------------------------------------------
  describe "GET #index" do
    it "lists only the current user's found items" do
      other_user.found_items.create!(
        item_type: "laptop",
        description: "MacBook found in Lerner",
        location: "Lerner Hall",
        found_date: Date.today,
        status: "active"
      )

      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:found_items)).to eq([found_item])
    end
  end

  # ---------------------------------------------------------
  # FEED – all users’ active found items
  # ---------------------------------------------------------
  describe "GET #feed" do
    it "lists all active found items across users" do
      other_item = other_user.found_items.create!(
        item_type: "wallet",
        description: "Brown wallet in Uris",
        location: "Uris Hall",
        found_date: Date.today,
        status: "active"
      )

      get :feed
      expect(response).to have_http_status(:ok)
      expect(assigns(:found_items)).to include(found_item, other_item)
    end

    it "does not include returned or closed items" do
      closed_item = other_user.found_items.create!(
        item_type: "id",
        description: "Student ID",
        location: "Lerner",
        found_date: Date.today,
        status: "closed"
      )

      get :feed
      expect(assigns(:found_items)).not_to include(closed_item)
    end
  end

  # ---------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------
  describe "GET #show" do
    it "renders the show page for the found item including photos" do
      get :show, params: { id: found_item.id }
      expect(response).to have_http_status(:ok)
      expect(assigns(:found_item)).to eq(found_item)
      expect(assigns(:found_item).photos_array).to include(
        "https://example.com/photo1.jpg",
        "https://example.com/photo2.jpg"
      )
    end
  end

  # ---------------------------------------------------------
  # CREATE
  # ---------------------------------------------------------
  describe "POST #create" do
    it "creates a new found item for the current user including photo URLs" do
      photo_urls = "https://example.com/pic1.jpg, https://example.com/pic2.jpg"

      expect {
        post :create, params: {
          found_item: {
            item_type: "wallet",
            description: "Brown leather wallet",
            location: "Low Library",
            found_date: Date.today,
            photos: photo_urls
          }
        }
      }.to change(FoundItem, :count).by(1)

      new_item = FoundItem.last
      expect(new_item.user).to eq(user)
      expect(new_item.photos_array).to eq(["https://example.com/pic1.jpg", "https://example.com/pic2.jpg"])
      expect(response).to redirect_to(found_item_path(new_item))
      expect(flash[:notice]).to eq("Your found item has been posted.")
    end
  end

  # ---------------------------------------------------------
  # MARK AS RETURNED
  # ---------------------------------------------------------
  describe "PATCH #mark_returned" do
    it "marks the item as returned if owned by current user" do
      patch :mark_returned, params: { id: found_item.id }
      expect(found_item.reload.status).to eq("returned")
      expect(flash[:notice]).to include("🎉 Item marked as returned")
    end

    it "does not allow marking another user's item" do
      other_item = other_user.found_items.create!(
        item_type: "wallet",
        description: "Someone else's item",
        location: "Library",
        found_date: Date.today
      )

      patch :mark_returned, params: { id: other_item.id }
      expect(other_item.reload.status).to eq("active")
      expect(flash[:alert]).to include("Could not mark as returned")
    end
  end

  # ---------------------------------------------------------
  # CLOSE LISTING
  # ---------------------------------------------------------
  describe "PATCH #close" do
    it "closes the listing if user owns it" do
      patch :close, params: { id: found_item.id }
      expect(found_item.reload.status).to eq("closed")
      expect(flash[:notice]).to include("📦 Listing closed successfully.")
    end

    it "does not allow closing someone else's listing" do
      other_item = other_user.found_items.create!(
        item_type: "id",
        description: "Student ID card",
        location: "Avery Hall",
        found_date: Date.today
      )

      patch :close, params: { id: other_item.id }
      expect(other_item.reload.status).to eq("active")
      expect(flash[:alert]).to include("Could not close this listing.")
    end
  end

  # ---------------------------------------------------------
  # CLAIM (feed-based)
  # ---------------------------------------------------------
  describe "PATCH #claim" do
    it "allows a non-owner to claim an active item" do
      allow(controller).to receive(:current_user).and_return(other_user)
      patch :claim, params: { id: found_item.id }

      expect(flash[:notice]).to include("✅ Claim request sent")
      expect(response).to redirect_to(feed_found_items_path)
    end

    it "prevents an owner from claiming their own item" do
      patch :claim, params: { id: found_item.id }
      expect(flash[:alert]).to eq("You cannot claim this item.")
    end
  end
end