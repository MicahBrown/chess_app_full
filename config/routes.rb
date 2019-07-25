Rails.application.routes.draw do
  devise_for :users

  resources :clubs
  resources :users, only: [:show]
  resources :games, only: [:index, :create, :show] do
    resources :pieces, only: [] do
      resources :moves, controller: :game_moves, only: [:create]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
end
