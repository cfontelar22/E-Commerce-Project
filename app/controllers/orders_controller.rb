class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_cart_data, only: [:create]

  def show
    @order = Order.find(params[:id])
    logger.debug "Order items: #{@order.order_items.inspect}"
  end

  def create
    @order = current_customer.orders.build(order_params)
    build_order_items(@cart)


    if @order.save
      # Clear the cart session
      session[:cart_items] = nil
      # Redirect to the show order path with the notice
      redirect_to order_path(@order), notice: 'Order was successfully placed.'
    else
      # If there are errors, log them and redirect back
      Rails.logger.info "Order save failed: #{@order.errors.full_messages.join(", ")}"
      flash[:alert] = 'There was a problem placing your order: ' + @order.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
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
    order_items.sum(&:total_price) 
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
end  