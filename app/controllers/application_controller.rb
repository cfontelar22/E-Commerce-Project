class ApplicationController < ActionController::Base
    def authenticate_admin!
        redirect_to new_admin_session_path unless current_admin && current_admin.is_a?(Admin)
      end      
end
