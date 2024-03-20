Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admins, ActiveAdmin::Devise.config

  # Define a single root path here
  # You need to choose which one you want as your root path.
  # If the admin dashboard is the landing page, use the line below:
  root to: 'admin/dashboard#index'

  # If you have another controller and action that serves as the homepage for non-admin users,
  # comment out the line above and uncomment the line below, replacing 'some_controller#some_action'
  # with the appropriate controller and action.
  # root to: 'some_controller#some_action'
end
