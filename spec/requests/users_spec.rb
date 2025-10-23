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
              email: 'nu1234@columbia.edu',
              first_name: 'John',
              last_name: 'Doe',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }.to change(User, :count).by(1)
      end

      it "redirects to dashboard" do
        post signup_path, params: {
          user: {
            email: 'nu1234@columbia.edu',
            first_name: 'John',
            last_name: 'Doe',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
        expect(response).to redirect_to(dashboard_path)
      end

      it "sets session" do
        post signup_path, params: {
          user: {
            email: 'nu1234@columbia.edu',
            first_name: 'John',
            last_name: 'Doe',
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
              first_name: 'John',
              last_name: 'Doe',
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
            first_name: 'John',
            last_name: 'Doe',
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

    context "with valid profile attributes" do
      it "updates profile information without password" do
        patch user_path(user), params: {
          user: {
            first_name: 'Updated',
            last_name: 'Name',
            bio: 'Updated bio',
            phone: '555-123-4567',
            contact_preference: 'phone',
            profile_visibility: 'private'
          }
        }
        
        user.reload
        expect(user.first_name).to eq('Updated')
        expect(user.last_name).to eq('Name')
        expect(user.bio).to eq('Updated bio')
        expect(user.phone).to eq('555-123-4567')
        expect(user.contact_preference).to eq('phone')
        expect(user.profile_visibility).to eq('private')
      end

      it "updates password when provided" do
        patch user_path(user), params: {
          user: {
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
        }
        expect(user.reload.authenticate('newpassword123')).to be_truthy
      end

      it "updates last_active_at when profile is updated" do
        original_time = user.last_active_at
        patch user_path(user), params: {
          user: {
            first_name: 'Updated'
          }
        }
        expect(user.reload.last_active_at).to be > original_time
      end

      it "redirects to user show page" do
        patch user_path(user), params: {
          user: {
            first_name: 'Updated'
          }
        }
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "with invalid profile attributes" do
      it "does not update with invalid phone format" do
        patch user_path(user), params: {
          user: {
            phone: 'invalid-phone'
          }
        }
        expect(user.reload.phone).not_to eq('invalid-phone')
      end

      it "does not update with invalid contact preference" do
        patch user_path(user), params: {
          user: {
            contact_preference: 'invalid'
          }
        }
        expect(user.reload.contact_preference).not_to eq('invalid')
      end

      it "does not update with invalid profile visibility" do
        patch user_path(user), params: {
          user: {
            profile_visibility: 'invalid'
          }
        }
        expect(user.reload.profile_visibility).not_to eq('invalid')
      end

      it "renders edit template on validation errors" do
        patch user_path(user), params: {
          user: {
            phone: 'invalid-phone'
          }
        }
        expect(response).to render_template(:edit)
      end
    end

    context "with password validation" do
      it "requires password confirmation when password is provided" do
        patch user_path(user), params: {
          user: {
            password: 'newpassword123',
            password_confirmation: 'differentpassword'
          }
        }
        expect(user.reload.authenticate('password123')).to be_truthy
      end

      it "allows blank passwords for profile updates" do
        patch user_path(user), params: {
          user: {
            first_name: 'Updated',
            password: '',
            password_confirmation: ''
          }
        }
        expect(user.reload.first_name).to eq('Updated')
        expect(user.authenticate('password123')).to be_truthy
      end
    end

    context "with profile photo upload" do
      it "accepts profile photo upload" do
        file = fixture_file_upload('test_image.jpg', 'image/jpeg')
        patch user_path(user), params: {
          user: {
            profile_photo: file
          }
        }
        expect(user.reload.profile_photo).to be_attached
      end
    end
  end
end