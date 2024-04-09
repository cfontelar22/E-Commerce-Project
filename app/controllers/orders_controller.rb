class OrdersController < ApplicationController
  before_action :set_cart_data, only: [:new, :create]
  

  def show
    @order = Order.find(params[:id])
  end
  
  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
    @order.build_customer
  end

  def create
    ActiveRecord::Base.transaction do
      @cart = Cart.new(session[:cart_items] || [])
      @order = Order.new(order_params)
      build_order_items(@cart) # This should add order_items to @order

      @subtotal = @cart.calculate_subtotal
      taxes = calculate_taxes(@order.customer.province, @subtotal)

      # Assign values to order attributes
      @order.subtotal = @subtotal
      @order.gst = taxes[:gst]
      @order.pst = taxes[:pst]
      @order.hst = taxes[:hst]
      @order.total = taxes[:total]

      if @order.save
        session[:cart] = nil
        redirect_to order_path(@order), notice: 'Order was successfully placed.'
      else
        render :new, alert: @order.errors.full_messages.to_sentence
      end
    rescue ActiveRecord::RecordInvalid => e
      render :new, alert: "There was an error placing your order: #{e.record.errors.full_messages.to_sentence}"
    end
  end
  
  private
  
  def build_order_items(cart)
    cart.items.each do |item_data|
      product = Product.find(item_data['product_id'])
      @order.order_items.build(product: product, quantity: item_data['quantity'], price: product.price)
    end
    @order.subtotal = @order.order_items.sum(&:total_price)
    tax_result = calculate_taxes(@order.customer.province, @order.subtotal)
    @order.assign_attributes(tax_result) # Assign tax attributes to @order
  end

  def set_cart_data
    session[:cart] ||= [] 
    @cart = Cart.new(session[:cart])
  end
end

  def order_params
    params.require(:order).permit(
      :subtotal, :gst, :pst, :hst, :total,
      customer_attributes: [:first_name, :last_name, :email, :phone_number, :address, :city, :province, :postal_code]
    )
  end

  def calculate_subtotal
    order_items.sum(&:total_price) # Ensure you have a 'total_price' method in OrderItem
  end

  def calculate_taxes(province, subtotal)
    # Define tax rates
    gst_rate = 0.05
    pst_rates = {
      'BC' => 0.07, # British Columbia
      'MB' => 0.07, # Manitoba
      'SK' => 0.06, # Saskatchewan
    }
    hst_rates = {
      'NL' => 0.15, # Newfoundland and Labrador
      'NB' => 0.15, # New Brunswick
      'NS' => 0.15, # Nova Scotia
      'PE' => 0.15, # Prince Edward Island
      'ON' => 0.13, # Ontario
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

    { gst: gst, pst: pst, hst: hst, total: subtotal + gst + pst + hst }
  end
