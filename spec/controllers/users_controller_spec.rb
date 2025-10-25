require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      email: "test#{Time.current.to_i}@columbia.edu",
      uni: "ts#{Time.current.to_i.to_s.last(4)}",
      first_name: 'John',
      last_name: 'Doe',
      password: 'password123',
      password_confirmation: 'password123'
    }
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'redirects to dashboard if already logged in' do
      session[:user_id] = user.id
      get :new
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new user' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it 'redirects to dashboard' do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets session' do
        post :create, params: { user: valid_attributes }
        expect(session[:user_id]).to eq(User.last.id)
      end
    end

    context 'with invalid attributes' do
      it 'renders new template' do
        post :create, params: { user: { email: 'invalid' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #show' do
    it 'returns http success when logged in' do
      session[:user_id] = user.id
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:success)
    end

    it 'redirects to login when not logged in' do
      get :show, params: { id: user.id }
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'GET #edit' do
    it 'returns http success when logged in' do
      session[:user_id] = user.id
      get :edit, params: { id: user.id }
      expect(response).to have_http_status(:success)
    end

    it 'redirects to login when not logged in' do
      get :edit, params: { id: user.id }
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'PATCH #update' do
    context 'with valid profile attributes' do
      it 'updates profile information without password' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { 
            first_name: 'Jane', 
            last_name: 'Smith',
            bio: 'Updated bio'
          } 
        }
        user.reload
        expect(user.first_name).to eq('Jane')
        expect(user.last_name).to eq('Smith')
        expect(user.bio).to eq('Updated bio')
      end

      it 'updates password when provided' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { 
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          } 
        }
        expect(response).to redirect_to(user_path(user))
      end

      it 'updates last_active_at when profile is updated' do
        session[:user_id] = user.id
        expect {
          patch :update, params: { 
            id: user.id, 
            user: { first_name: 'Updated' } 
          }
        }.to change { user.reload.last_active_at }
      end

      it 'redirects to user show page' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { first_name: 'Updated' } 
        }
        expect(response).to redirect_to(user_path(user))
      end
    end

    context 'with invalid profile attributes' do
      it 'does not update with invalid phone format' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { phone: 'invalid-phone' } 
        }
        expect(user.reload.phone).not_to eq('invalid-phone')
      end

      it 'does not update with invalid contact preference' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { contact_preference: 'invalid' } 
        }
        expect(user.reload.contact_preference).not_to eq('invalid')
      end

      it 'does not update with invalid profile visibility' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { profile_visibility: 'invalid' } 
        }
        expect(user.reload.profile_visibility).not_to eq('invalid')
      end

      it 'renders edit template on validation errors' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { first_name: '' } 
        }
        expect(response).to render_template(:edit)
      end
    end

    context 'with password validation' do
      it 'requires password confirmation when password is provided' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { 
            password: 'newpassword123',
            password_confirmation: ''
          } 
        }
        expect(response).to render_template(:edit)
      end

      it 'allows blank passwords for profile updates' do
        session[:user_id] = user.id
        patch :update, params: { 
          id: user.id, 
          user: { 
            first_name: 'Updated',
            password: '',
            password_confirmation: ''
          } 
        }
        expect(response).to redirect_to(user_path(user))
      end
    end

    context 'with profile photo upload' do
      it 'accepts profile photo upload' do
        session[:user_id] = user.id
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg')
        patch :update, params: { 
          id: user.id, 
          user: { profile_photo: file } 
        }
        expect(user.reload.profile_photo).to be_attached
      end
    end
  end
end
