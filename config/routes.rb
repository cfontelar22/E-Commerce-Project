Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admins, ActiveAdmin::Devise.config

  # Static Pages routes
  get '/about', to: 'pages#about', as: 'about'
  get '/contact', to: 'pages#contact', as: 'contact'
  
  # Checkout Pages routes

  resources :orders, only: [:show, :create, :new]
  # This route will handle displaying the checkout form
  get '/checkout', to: 'checkout#new', as: 'new_checkout'

  # This route will handle the form submission
  post 'checkout', to: 'checkout#create', as: 'create_checkout'

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

 # This route handles showing the order summary after a purchase
  get 'orders/:id/summary', to: 'orders#index', as: 'order_summary'


  # Order routes
  resources :orders, only: [:index, :show, :create, :new]
  

  # Categories routes
  resources :categories, only: [:index, :show] do
    # Nested route for products under a category
    resources :products, only: :index, as: :category_products
  end
end