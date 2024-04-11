Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admins, ActiveAdmin::Devise.config
  devise_for :customers
 
  # Static Pages routes
  get '/about', to: 'pages#about', as: 'about'
  get '/contact', to: 'pages#contact', as: 'contact'

  # Root path for landing page
  root to: 'pages#home'
  get 'home', to: 'pages#home', as: 'home'

  # Checkout Pages routes
  resource :checkout, only: [:new, :create], controller: 'checkout'

  # Products routes
  resources :products, only: [:index, :show]

  # Cart routes
  resource :cart, only: [:show] do
    post 'add', on: :collection, to: 'carts#create', as: 'add_to_cart'
    patch 'update_item/:product_id', on: :member, to: 'carts#update', as: 'update_item'
    delete 'remove_item/:product_id', on: :member, to: 'carts#destroy', as: 'remove_item'
  end

  # Order routes
  resources :orders, only: [:show, :create, :new]

  # Categories routes
  resources :categories, only: [:index, :show] do
    # Nested route for products under a category
    resources :products, only: :index, as: :category_products
  end
end
