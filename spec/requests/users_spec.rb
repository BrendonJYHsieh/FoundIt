require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "returns http success" do
      get signup_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to dashboard if already logged in" do
      user = create(:user)
      post login_path, params: { email: user.email, password: 'password123' }
      get signup_path
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "POST /signup" do
    context "with valid attributes" do
      it "creates a new user" do
        expect {
          post signup_path, params: {
            user: {
              email: 'newuser@columbia.edu',
              uni: 'nu1234',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }.to change(User, :count).by(1)
      end

      it "redirects to dashboard" do
        post signup_path, params: {
          user: {
            email: 'newuser@columbia.edu',
            uni: 'nu1234',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
        expect(response).to redirect_to(dashboard_path)
      end

      it "sets session" do
        post signup_path, params: {
          user: {
            email: 'newuser@columbia.edu',
            uni: 'nu1234',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
        expect(session[:user_id]).to be_present
      end
    end

    context "with invalid attributes" do
      it "does not create a user with invalid email" do
        expect {
          post signup_path, params: {
            user: {
              email: 'invalid@gmail.com',
              uni: 'nu1234',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }.not_to change(User, :count)
      end

      it "renders new template" do
        post signup_path, params: {
          user: {
            email: 'invalid@gmail.com',
            uni: 'nu1234',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET /users/:id" do
    let(:user) { create(:user) }

    it "returns http success when logged in" do
      post login_path, params: { email: user.email, password: 'password123' }
      get user_path(user)
      expect(response).to have_http_status(:success)
    end

    it "redirects to login when not logged in" do
      get user_path(user)
      expect(response).to redirect_to(login_path)
    end
  end

  describe "GET /users/:id/edit" do
    let(:user) { create(:user) }

    it "returns http success when logged in" do
      post login_path, params: { email: user.email, password: 'password123' }
      get edit_user_path(user)
      expect(response).to have_http_status(:success)
    end

    it "redirects to login when not logged in" do
      get edit_user_path(user)
      expect(response).to redirect_to(login_path)
    end
  end

  describe "PATCH /users/:id" do
    let(:user) { create(:user) }

    before do
      post login_path, params: { email: user.email, password: 'password123' }
    end

    context "with valid attributes" do
      it "updates the user" do
        patch user_path(user), params: {
          user: { email: 'updated@columbia.edu' }
        }
        expect(user.reload.email).to eq('updated@columbia.edu')
      end

      it "redirects to user show page" do
        patch user_path(user), params: {
          user: { email: 'updated@columbia.edu' }
        }
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "with invalid attributes" do
      it "does not update the user" do
        patch user_path(user), params: {
          user: { email: 'invalid@gmail.com' }
        }
        expect(user.reload.email).not_to eq('invalid@gmail.com')
      end

      it "renders edit template" do
        patch user_path(user), params: {
          user: { email: 'invalid@gmail.com' }
        }
        expect(response).to render_template(:edit)
      end
    end
  end
end