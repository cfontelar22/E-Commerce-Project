class CheckoutController < ApplicationController
  before_action :set_cart, only: [:new, :create]
  before_action :set_customer, only: [:new, :create]

  def new
    # @order = Order.new
    @cart = Cart.new(session[:cart_items] || [])
    @total_price = @cart.total_price
    @customer = Customer.new
    set_provinces
  end

  def create
    ActiveRecord::Base.transaction do
      @order = Order.new(order_params)
      @order.subtotal = calculate_subtotal(@order)
      calculate_and_assign_taxes(@order)

      if @order.save
        # Handle Stripe payment
        if handle_payment(@order)
          clear_cart
          redirect_to order_path(@order), notice: 'Order was successfully placed.'
        else
          @order.destroy
          flash.now[:alert] = 'There was a problem with your payment.'
          render :new
        end
      else
        set_provinces
        flash.now[:alert] = 'There was a problem with your order.'
        render :new
      end
    rescue ActiveRecord::RecordInvalid => e
      set_provinces
      flash.now[:alert] = 'An error occurred while processing your order.'
      render :new
    rescue Stripe::CardError => e
      flash.now[:alert] = e.message
      render :new
    end
  end
  
  private

  def set_cart
    session_cart = session[:cart] || []
    @cart = Cart.new(session_cart)
  end

  # Handles payment processing and logs each step for debugging purposes
    def handle_payment(order)
      Rails.logger.info "handle_payment: Starting payment process for Order ID: #{order.id}"
      
      begin
        # Retrieve the Stripe token from parameters
        token = params[:stripeToken]
        
        # Log the Stripe token received from the front-end
        Rails.logger.info "handle_payment: Stripe token received: #{token}"
        
        # Perform the checkout operation using the Stripe service
        charge = StripeCheckoutService.checkout(order, token)
        
        # Log the result of the checkout operation
        if charge.paid
          Rails.logger.info "handle_payment: Payment completed for Order ID: #{order.id}"
          order.update(payment_status: 'paid', stripe_charge_id: charge.id)
          return true
        else
          Rails.logger.error "handle_payment: Payment failed for Order ID: #{order.id}. Error: #{charge.failure_message}"
          return false
        end
      rescue Stripe::CardError => e
        # Log Stripe errors (e.g., card declines, invalid requests)
        Rails.logger.error "handle_payment: StripeError - #{e.message}"
        raise
      rescue => e
        # Log any other type of standard error
        Rails.logger.error "handle_payment: StandardError - #{e.message}"
        raise
      end
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

  def calculate_subtotal(order)
    order.order_items.sum(&:total_price)
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
