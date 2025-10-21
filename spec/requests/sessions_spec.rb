require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get "/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    it "returns http success" do
      post "/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /logout" do
    it "redirects after logout" do
      delete "/logout"
      expect(response).to have_http_status(:redirect)
    end
  end

end
