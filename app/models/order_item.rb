class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product
  validates :product_id, uniqueness: { scope: :order_id, message: "should happen once per order" }


  def total_price
    (quantity || 0) * (price || 0.0)
  end  
end
