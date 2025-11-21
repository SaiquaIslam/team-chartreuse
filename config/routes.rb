Rails.application.routes.draw do
  devise_for :users
  
  # Reveal health status on /up
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root "corpse_flowers#index"

  # Corpse Flowers routes (US01, US02, US03)
  resources :corpse_flowers, only: [:index, :show]

  # Admin routes
namespace :admin do
  resources :corpse_flowers do
    member do
      patch :increase_stock
      patch :decrease_stock
    end
  end
end



end
