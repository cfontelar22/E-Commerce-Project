class Order < ApplicationRecord
  # Establishes association with the Customer model
  belongs_to :customer
  # Allows for nested attributes for the associated customer
  accepts_nested_attributes_for :customer
  
  # Establishes association with the OrderItem model
  has_many :order_items, dependent: :destroy
  
  # Allows for nested attributes for order items
  accepts_nested_attributes_for :order_items
  
  # A callback to set taxes and total before saving an order
  before_save :set_taxes_and_total

  # Defines searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["address", "created_at", "customer_id", "gst", "hst", "id", "id_value", "pst", "subtotal", "total", "updated_at"]
  end

  # Calculates the total price of the order by summing up the total price of each item
  def calculate_subtotal
    order_items.sum(&:total_price)
  end

  private

  # Constants for tax rates
  GST_RATE = 0.05
  PST_RATES = {
    'BC' => 0.07,
    'MB' => 0.07,
    'SK' => 0.06,
    # Add other provinces as needed
  }
  HST_RATES = {
    'NL' => 0.15,
    'NB' => 0.15,
    'NS' => 0.15,
    'PE' => 0.15,
    'ON' => 0.13,
    # Add other provinces as needed
  }

  # A method to calculate taxes based on the customer's province and the order subtotal
  def calculate_taxes(province, subtotal)
    gst = subtotal * GST_RATE
    pst = PST_RATES[province] ? subtotal * PST_RATES[province] : 0
    hst = HST_RATES[province] ? subtotal * HST_RATES[province] : 0

    # Ensure that GST is set to 0 if HST is applicable
    gst = 0 if hst.positive?

    { gst: gst, pst: pst, hst: hst }
  end

  # A method to set taxes and total for an order
  def set_taxes_and_total
    self.subtotal = calculate_subtotal
    tax_result = calculate_taxes(customer.province, subtotal)
    self.gst = tax_result[:gst]
    self.pst = tax_result[:pst]
    self.hst = tax_result[:hst]
    self.total = self.subtotal + self.gst + self.pst + self.hst
  end
end
