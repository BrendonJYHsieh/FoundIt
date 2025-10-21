require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    it "redirects to login when not authenticated" do
      get "/dashboard"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(login_path)
    end
    
    it "returns http success when authenticated" do
      user = create(:user)
      sign_in user
      get "/dashboard"
      expect(response).to have_http_status(:success)
    end
  end

end
