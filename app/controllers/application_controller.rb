class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_cart_data
  helper_method :current_admin, :authenticate_admin!

  private

  def set_cart_data
    @cart = Cart.new(session[:cart_items] || [])
    @total_price = @cart.total_price
    @item_count = @cart.items.sum { |item| item['quantity'] }
  end

  def authenticate_admin!
    redirect_to new_admin_session_path unless current_admin && current_admin.is_a?(Admin)
  end


  protected

    def configure_permitted_parameters
      # For additional fields in app/views/devise/registrations/new.html.erb
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :address, :city, :province, :postal_code, :phone_number])
  
      # For additional fields in app/views/devise/registrations/edit.html.erb
      devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :address, :city, :province, :postal_code, :phone_number])
    end
end
