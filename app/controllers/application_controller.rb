class ApplicationController < ActionController::Base
  before_action :set_cart_data
  helper_method :current_admin, :authenticate_admin!

  def set_cart_data
    @cart = Cart.new(session[:cart_items] || [])
    @total_price = @cart.total_price
    @item_count = @cart.items.sum { |item| item['quantity'] }
  end
end

  private

  def authenticate_admin!
    redirect_to new_admin_session_path unless current_admin && current_admin.is_a?(Admin)
  end
