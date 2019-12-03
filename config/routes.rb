Rails.application.routes.draw do
  devise_for :users
  root "users#index"
  
  resources :avatars, only: [:new, :create, :edit, :update]
  resources :stations, only: [:index]
  resources :users, only: [:index, :edit, :update, :show]
end
