ActiveAdmin.setup do |config|
  # ... other configurations ...

  # == User Authentication
  # This setting changes the method which Active Admin calls
  # within the application controller to ensure a currently logged in admin.
  config.authentication_method = :authenticate_admin!

  # == Current User
  # This setting changes the method which Active Admin calls
  # (within the application controller) to return the currently logged in user.
  config.current_user_method = :current_admin

  # == Logging Out
  # This setting changes the path where the logout link points to.
  config.logout_link_path = :destroy_admin_session_path

  # This setting changes the http method used when rendering the
  # link. For example :get, :delete, :put, etc..
  config.logout_link_method = :delete
end