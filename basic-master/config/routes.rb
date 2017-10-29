Rails.application.routes.draw do

  root "pages#home"

  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :sessions,      only: [:new, :create, :destroy]
  resources :microposts,    only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]

  get 'mentions', to: 'users#mentions'
  get    "signup"  => "users#new"
  get    "signin"  => "sessions#new"
  get    "help"    => "pages#help"

  delete "signout" => "sessions#destroy"
end
