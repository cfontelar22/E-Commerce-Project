class CheckoutController < ApplicationController
  before_action :set_cart, only: [:new, :create]
  before_action :set_customer, only: [:new, :create]

 def new
  @order = Order.new
  @cart.items.each do |cart_item|
    product = Product.find(cart_item['product_id'])
    @order.order_items.build(product: product, quantity: cart_item['quantity'], price: product.price)
  end
  @customer = Customer.new
  @total_price = @cart.total_price
  set_provinces
end

  def create
    ActiveRecord::Base.transaction do
      # Initialize a new Order from the order_params, which should include nested attributes for the customer
      @order = Order.new(order_params)
      
      if @order.save
        # Clear the cart
        clear_cart
        # Redirect to the order summary page
        redirect_to order_summary_path(@order), notice: 'Order was successfully placed.'
      else
        # If there was a problem saving the order, handle it here
        set_provinces
        flash.now[:alert] = 'There was a problem with your order.'
        render :new
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # If there's an exception, handle it here
    set_provinces
    flash.now[:alert] = 'An error occurred while processing your order.'
    render :new
  end
  
  private

  def set_cart
    session_cart = session[:cart] || []
    @cart = Cart.new(session_cart)
  end

  def customer_params
    params.require(:order).permit(:total, customer_attributes: [:first_name, :last_name, :email, :phone_number, :address, :city, :province, :postal_code])[:customer_attributes]
  end
  

  def order_params
    params.require(:order).permit(:subtotal, order_items_attributes: [:product_id, :quantity])
  end

  def set_customer
    @customer = session[:customer_id] ? Customer.find_by(id: session[:customer_id]) : Customer.new
  end

  def calculate_taxes(province, subtotal)
    set_provinces
    province_abbr = @provinces_in_canada[province]

    tax_rates = {

    }

    unless province_abbr && tax_rates[province_abbr]
      Rails.logger.error "Tax rates not defined for province: #{province}"
      return { gst: 0, pst: 0, hst: 0, total: subtotal }
    end

    taxes = tax_rates[province_abbr]
    gst = taxes[:gst] ? subtotal * taxes[:gst] : 0
    pst = taxes[:pst] ? subtotal * taxes[:pst] : 0
    hst = taxes[:hst] ? subtotal * taxes[:hst] : 0
    gst = 0 if hst.positive?

    { gst: gst, pst: pst, hst: hst, total: subtotal + gst + pst + hst }
  end

  def set_provinces
    @provinces_in_canada = {
      'Alberta' => 'AB',
      'British Columbia' => 'BC',
      'Manitoba' => 'MB',
      'New Brunswick' => 'NB',
      'Newfoundland and Labrador' => 'NL',
      'Nova Scotia' => 'NS',
      'Northwest Territories' => 'NT',
      'Nunavut' => 'NU',
      'Ontario' => 'ON',
      'Prince Edward Island' => 'PE',
      'Quebec' => 'QC',
      'Saskatchewan' => 'SK',
      'Yukon' => 'YT'
    }
  end

  def clear_cart
    session[:cart] = nil
  end

  def order_path(order)
  end
end
