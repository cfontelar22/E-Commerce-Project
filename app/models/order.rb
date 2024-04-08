class Order < ApplicationRecord
  belongs_to :customer
  accepts_nested_attributes_for :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  
  # Validate presence of order attributes
  validates :subtotal, :gst, :pst, :hst, :total, presence: true

  # Add a method to calculate and update taxes and total
  def update_taxes_and_total!
    # Implementation of tax calculation logic 
    self.gst = subtotal * GST_RATE
    self.pst = subtotal * PST_RATE
    self.hst = subtotal * HST_RATE
    # Ensure that GST is set to 0 if HST is present, as HST includes GST
    self.gst = 0 if self.hst.positive?

    # Update the total
    self.total = subtotal + gst + pst + hst
  end

  private

  def set_totals
    self.subtotal = order_items.sum(&:total_price)
    tax_result = calculate_taxes(customer.province, subtotal)
    self.gst = tax_result[:gst]
    self.pst = tax_result[:pst]
    self.hst = tax_result[:hst]
    self.total = tax_result[:total]
  end

  def calculate_subtotal
    order_items.sum(&:total_price)
  end
end

