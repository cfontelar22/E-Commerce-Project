Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admins, ActiveAdmin::Devise.config

  # Static Pages routes
  get '/about', to: 'pages#about', as: 'about'
  get '/contact', to: 'pages#contact', as: 'contact'

  # Root path for landing page
  root to: 'pages#home'

  # Products routes
  resources :products, only: [:index, :show]

  # Cart routes
  resource :cart, only: [:show] do
    post 'add', on: :collection, to: 'carts#create', as: 'add_to_cart'
    patch 'update_item/:product_id', on: :member, to: 'carts#update', as: 'update_item'
    delete 'remove_item/:product_id', on: :member, to: 'carts#destroy', as: 'remove_item'
  end
  


  # Categories routes
  resources :categories, only: [:index, :show] do
    # Nested route for products under a category
    resources :products, only: :index, as: :category_products
  end
end
