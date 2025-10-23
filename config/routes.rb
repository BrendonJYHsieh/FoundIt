Rails.application.routes.draw do
  root "pages#home"
  
  # User authentication routes
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  # User profile routes
  resources :users, only: [:show, :edit, :update, :create]
  
  # Lost items routes
  resources :lost_items do
    collection do
      get :all
    end
    member do
      patch :mark_found
      patch :close
    end
    resources :matches, only: [:index, :show]
  end
  
  # Found items routes
  resources :found_items do
    member do
      patch :mark_returned
      patch :close
      patch :claim
    end
    collection do
      get :feed 
      patch :claim
    end
    resources :matches, only: [:index, :show]
  end  

  # Matches routes
  resources :matches, only: [:index, :show] do
    member do
      patch :approve
      patch :reject
    end
  end  
  
  # Dashboard routes
  get "dashboard", to: "dashboard#index"
  
  # API routes for mobile app
  namespace :api do
    namespace :v1 do
      resources :lost_items, only: [:index, :show, :create]
      resources :found_items, only: [:index, :show, :create]
      resources :matches, only: [:index, :show, :update]
    end
  end
end