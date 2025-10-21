Rails.application.routes.draw do
  root "pages#home"
  
  # User authentication routes
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  # User profile routes
  resources :users, only: [:show, :edit, :update]
  
  # Lost items routes
  resources :lost_items do
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
    end
    resources :matches, only: [:index, :show]
  end
  
  # Match verification routes
  resources :matches, only: [:show, :update] do
    member do
      patch :verify
      patch :reject
      patch :complete
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