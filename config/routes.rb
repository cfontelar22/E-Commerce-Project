Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admins, ActiveAdmin::Devise.config

  # Root path for landing page
  root to: 'admin/dashboard#index'

  # Static Pages routes
  get '/about', to: 'pages#about', as: 'about'
  get '/contact', to: 'pages#contact', as: 'contact'

   # Route for the products listing
   get 'products', to: 'products#index', as: 'products'
  
   # Route for filtering by category
   get 'categories/:category', to: 'products#index', as: 'category_products'
   
   # Route for product details
   get 'products/:id', to: 'products#show', as: 'product'
   
end
