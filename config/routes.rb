Rails.application.routes.draw do
  devise_for :users
  root "users#index"
  
  resources :avatars, only: [:new, :create, :edit, :update] do
    collection do
      get 'travel'
      get 'reload'
    end
  end
  resources :stations, only: [:index]
  resources :users, only: [:index, :edit, :update, :show] do
    collection do
      get 'reload'
    end
  end
end
