require 'rails_helper'

RSpec.describe "Matches", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/matches/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/matches/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/matches/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/matches/update"
      expect(response).to have_http_status(:success)
    end
  end

end
