Rails.application.routes.draw do
  devise_for :users
  root "users#index"
  resources :users, only: [:index, :edit, :update, :show]
  resources :avatars, only: [:new, :create]

  resources :stations, only: [:index]
end
