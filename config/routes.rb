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

  # Categories routes
  resources :categories, only: [:index, :show] do
    # Nested route for products under a category
    resources :products, only: :index, as: :category_products
  end
end
