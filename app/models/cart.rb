class Cart
  attr_reader :items

  def initialize(session_cart)
    @items = session_cart.map do |item|
      { 'product_id' => item['product_id'].to_i, 'quantity' => item['quantity'].to_i }
    end
  end

  # Make sure total_price is a public method
  def total_price
    @items.sum do |item|
      product = Product.find(item['product_id'])
      product.price * item['quantity']
    end
  end

  def add_product(product_id, quantity = 1)
    product_id = product_id.to_i
    current_item = @items.find { |item| item['product_id'] == product_id }
    if current_item
      current_item['quantity'] += quantity
    else
      @items << { 'product_id' => product_id, 'quantity' => quantity }
    end
  end

  def update_quantity(product_id, quantity)
    product_id = product_id.to_i
    current_item = @items.find { |item| item['product_id'] == product_id }
    current_item['quantity'] = quantity if current_item
  end

  def remove_product(product_id)
    product_id = product_id.to_i
    @items.delete_if { |item| item['product_id'] == product_id }
  end


  # Helper method to get a list of products
  def products
    @items.map do |item|
      product = Product.find_by(id: item['product_id'])
      { product: product, quantity: item['quantity'] } if product
    end.compact
  end
end

def calculate_subtotal
  order_items.sum(&:total_price) # Ensure you have a 'total_price' method in OrderItem
end
