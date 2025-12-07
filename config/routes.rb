# frozen_string_literal: true

Rails.application.routes.draw do
  # Devise Authentication (Sajal PR1)
  devise_for :users

  # Root route - Browse page
  root "corpse_flowers#index"

  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Corpse Flowers - Browse & Search (Tanvir PR1, PR2)
  resources :corpse_flowers, only: [:index, :show] do
    resources :reviews, only: [:new, :create]
  end

  resources :messages, only: [:new, :create]

  # Cart System (Tanvir PR3)
  resource :cart, only: [:show]
  resources :cart_items, only: [:create, :update, :destroy]

  # Checkout - PR1/PR2/PR3
  namespace :checkout do
    # Shipping (Rafy PR1)
    get  'shipping', to: 'shippings#new'
    post 'shipping', to: 'shippings#create'

    # Payment (Rafy PR2)
    get  'payment', to: 'payments#new'
    post 'payment', to: 'payments#create'

    # Review + Finalize Order (Rafy PR3, US12)
    get  'review', to: 'reviews#show'
    post 'review', to: 'reviews#create'

    # Confirmation (Rafy PR3, US12)
    get  'confirmation/:id', to: 'confirmations#show', as: :confirmation
  end

  # Purchase history (Rafy PR3, US13)
  resources :orders, only: [:index, :show]

  # Hunt Registration (Saiqua)
  # Hunt list page (US25)
  get "hunt", to: "hunt_registration#index", as: :hunt

    # Hunt Register page (US22)
  get  "hunt_registration/new", to: "hunt_registration#new",    as: "new_hunt_registration"
  post "hunt_registration",     to: "hunt_registration#create", as: "hunt_registrations"
  get  "hunt_registration/:id", to: "hunt_registration#show",   as: "hunt_registration_show"
  get  "hunt_registration/:id/edit", to: "hunt_registration#edit", as: "edit_hunt_registration"
  patch "hunt_registration/:id", to: "hunt_registration#update", as: "hunt_registration"
  get  "hunt_registration/:id/remove", to: "hunt_registration#confirm_remove", as: "confirm_remove_hunt_registration"
  delete "hunt_registration/:id", to: "hunt_registration#destroy", as: "delete_hunt_registration"

  # Visit Routes (Manual Style like HuntRegistration)
get  "hunt_registration/:hunt_registration_id/visit/new",  to: "visits#new", as: "new_hunt_registration_visit"

post "hunt_registration/:hunt_registration_id/visit", to: "visits#create", as: "hunt_registration_visits"

# Leaderboard Route
get "leaderboard", to: "visits#leaderboard", as: "leaderboard"


   
  #root "hunt_registration#new"
  # Defines the root path route ("/")
  # root "posts#index"

  ##################################################################
  # Admin Routes (Sajal M1PR1, M2 PR2, M2 PR3, M2 PR3)
  ##################################################################
  namespace :admin do
  # === Flowers ===
  resources :corpse_flowers do
    member do
      patch :increase_stock
      patch :decrease_stock
    end
  end

  # === Users (US29) ===
  resources :users, only: [:index] do
    member do
      patch :suspend
      patch :unsuspend
    end
  end

  # === Dashboard ===
  get "dashboard", to: "dashboard#index"

# NEW for moderation
  resources :moderations, only: [:index, :destroy]

end


end