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

  # Cart System (Tanvir PR3)
  resource :cart, only: [:show]
  resources :cart_items, only: [:create]

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

   
  #root "hunt_registration#new"
  # Defines the root path route ("/")
  # root "posts#index"

  ##################################################################
  # Admin Routes (Sajal PR2)
  ##################################################################
  namespace :admin do
    resources :corpse_flowers
  end
end
