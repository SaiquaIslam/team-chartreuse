# frozen_string_literal: true

Rails.application.routes.draw do
  # Devise Authentication (Sajal PR1)
  devise_for :users

  # Root route - Browse page
  root "corpse_flowers#index"

  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Corpse Flowers - Browse & Search (Tanvir PR1, PR2)
  resources :corpse_flowers, only: [:index, :show]

  # Cart System (Tanvir PR3)
  resource :cart, only: [:show]
  resources :cart_items, only: [:create]

  # Checkout (Rafy PR1, PR2)
  namespace :checkout do
    get  'shipping', to: 'shippings#new'
    post 'shipping', to: 'shippings#create'
    get  'payment', to: 'payments#new'
    post 'payment', to: 'payments#create'
  end

  # Hunt Registration (Saiqua)
  get  "hunt_registration/new", to: "hunt_registration#new",    as: "new_hunt_registration"
  post "hunt_registration",     to: "hunt_registration#create", as: "hunt_registrations"
end