class Cart
  attr_reader :items

  def initialize(session_cart)
    @items = session_cart || []
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

  def total_price
    @items.sum do |item|
      product = Product.find_by(id: item['product_id'])
      product ? product.price * item['quantity'] : 0
    end
  end

  # Helper method to get a list of products
  def products
    @items.map do |item|
      product = Product.find_by(id: item['product_id'])
      { product: product, quantity: item['quantity'] } if product
    end.compact
  end
end
