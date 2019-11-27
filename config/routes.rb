Rails.application.routes.draw do
  devise_for :users
  root "travels#index"
  resources :users, only: [:edit, :update, :index]
end
