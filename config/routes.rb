Rails.application.routes.draw do
    devise_for :users, :controllers => {
   :registrations => 'users/registrations',
   :sessions => 'users/sessions',
   :passwords => 'users/passwords'
  }
  
  root "users#index"
  
  resources :avatars, only: [:new, :create, :edit, :update] do
    collection do
      get 'travel'
      get 'reload'
    end
  end
  resources :stations, only: [:index] do
    collection do
      get 'get_name'
    end
  end
  resources :users, only: [:index, :edit, :update, :show] do
    collection do
      get 'reload'
    end
  end
end
