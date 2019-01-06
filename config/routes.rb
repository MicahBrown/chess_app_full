Rails.application.routes.draw do
  devise_for :users

  resources :clubs
  resources :users, only: [:show]
  resources :games, only: [:index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
end
