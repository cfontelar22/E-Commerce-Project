class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_cart_data, only: [:create]

  def show
    @order = Order.find(params[:id])
    logger.debug "Order items: #{@order.order_items.inspect}"
  end

 def create
    @order = current_customer.orders.build(order_params)
    build_order_items(@cart) # This populates @order with order_items

    # Calculate subtotal after building order items
    @order.subtotal = calculate_subtotal
    taxes = calculate_taxes(@order.customer.province, @order.subtotal)
    @order.assign_attributes(taxes)

    # Start Stripe payment processing
    stripe_token = params[:stripeToken]
    payment_status = process_payment(stripe_token, @order.total)

    if payment_status[:success]
      @order.update(status: 'paid', payment_id: payment_status[:payment_id])

      # Clear the cart session
      session[:cart_items] = nil
      # Redirect to the show order path with the notice
      redirect_to order_path(@order), notice: 'Order was successfully placed.'
    else
      # If there is an error during payment, log it and redirect back
      logger.error "Payment failed: #{payment_status[:error]}"
      flash[:alert] = 'There was a problem with the payment: ' + payment_status[:error]
      redirect_back(fallback_location: root_path)
    end
  rescue Stripe::CardError => e
    flash[:alert] = e.message
    redirect_back(fallback_location: root_path)
  end

  private

  def set_cart_data
    @cart = Cart.new(session[:cart_items] || [])
  end

  def build_order_items(cart)
    cart.items.each do |item_data|
      product = Product.find(item_data['product_id'])
      unless product.nil?
        order_item = @order.order_items.build(
          product: product,
          quantity: item_data['quantity'],
          price: product.price
        )
        logger.debug "Building order item: #{order_item.inspect}"
      end
    end
  end
  
  
  def order_params
  params.require(:order).permit(:subtotal, :gst, :pst, :hst, :total,
                                customer_attributes: [:address, :city, :province, :postal_code, :phone_number],
                                order_items_attributes: [:product_id, :quantity, :price])
end
  

  def address_provided?
    params[:address].present? && params[:city].present? && params[:province].present? && params[:postal_code].present?
  end
  
  def address_params
    params.permit(:address, :city, :province, :postal_code, :phone_number)
  end

  def calculate_subtotal
    @order.order_items.sum(&:total_price) 
  end
  

  def calculate_taxes(province, subtotal)
    # Define federal GST rate
    gst_rate = 0.05
  
    # Define PST rates for provinces with separate GST and PST
    pst_rates = {
      'BC' => 0.07, # British Columbia
      'MB' => 0.07, # Manitoba
      'SK' => 0.06, # Saskatchewan
      'QC' => 0.09975 # Quebec
    }
  
    # Define HST rates for provinces with Harmonized Sales Tax
    hst_rates = {
      'NL' => 0.15, # Newfoundland and Labrador
      'NB' => 0.15, # New Brunswick
      'NS' => 0.15, # Nova Scotia
      'PE' => 0.15, # Prince Edward Island
      'ON' => 0.13  # Ontario
    }
  
    # Initialize taxes
    gst = pst = hst = 0
  
    # Apply HST if applicable
    if hst_rates[province]
      hst = subtotal * hst_rates[province]
    else
      # Apply GST
      gst = subtotal * gst_rate
      # Apply PST if applicable
      pst = subtotal * pst_rates[province] if pst_rates[province]
    end
  
    # Provinces and territories without PST or HST
    no_pst_or_hst = ['YT', 'NT', 'NU'] # Yukon, Northwest Territories, Nunavut
    if no_pst_or_hst.include?(province)
      gst = subtotal * gst_rate
      pst = 0
    end
  
    { gst: gst, pst: pst, hst: hst, total: subtotal + gst + pst + hst }
  end

  def process_payment(stripe_token, total)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  
    begin
      # Since Stripe will throw an error if the token has been used,
      charge = Stripe::Charge.create(
        amount: (total * 100).to_i, # Stripe expects the amount in cents
        currency: 'cad',
        description: 'Order payment',
        source: stripe_token
      )
  
      { success: charge.paid, payment_id: charge.id }
    rescue Stripe::InvalidRequestError => e
      # Handle the case where the Stripe token has already been used
      { success: false, error: 'The payment could not be processed because the token has already been used.' }
    rescue Stripe::CardError => e
      # Handle any card errors (like insufficient funds, etc.)
      { success: false, error: e.message }
    end
  end
end 