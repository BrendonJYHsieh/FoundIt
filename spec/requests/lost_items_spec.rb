require 'rails_helper'

RSpec.describe "LostItems", type: :request do
  let(:user) { create(:user) }
  
  before do
    sign_in user
  end

  describe "GET /lost_items" do
    it "returns http success" do
      get "/lost_items"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /lost_items/:id" do
    let(:lost_item) { create(:lost_item, user: user) }
    
    it "returns http success" do
      get "/lost_items/#{lost_item.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /lost_items/new" do
    it "returns http success" do
      get "/lost_items/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /lost_items" do
    it "redirects after successful creation" do
      post "/lost_items", params: { lost_item: attributes_for(:lost_item) }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /lost_items/:id/edit" do
    let(:lost_item) { create(:lost_item, user: user) }
    
    it "returns http success" do
      get "/lost_items/#{lost_item.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /lost_items/:id" do
    let(:lost_item) { create(:lost_item, user: user) }
    
    it "redirects after successful update" do
      patch "/lost_items/#{lost_item.id}", params: { lost_item: { description: "Updated description" } }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /lost_items/:id" do
    let(:lost_item) { create(:lost_item, user: user) }
    
    it "redirects after successful deletion" do
      delete "/lost_items/#{lost_item.id}"
      expect(response).to have_http_status(:redirect)
    end
  end

end
