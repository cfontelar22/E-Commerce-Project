class Order < ApplicationRecord
  belongs_to :customer
  accepts_nested_attributes_for :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  
  before_save :set_taxes_and_total

   # Defines a class method to allowlist searchable attributes for Ransack.
   def self.ransackable_attributes(auth_object = nil)
    # Only the attributes you want to be searchable.
    ["address", "created_at", "customer_id", "gst", "hst", "id", "id_value", "pst", "subtotal", "total", "updated_at"]
  end


  def set_taxes_and_total
    self.subtotal = calculate_subtotal
    tax_result = calculate_taxes(customer.province, subtotal)
    self.gst = tax_result[:gst]
    self.pst = tax_result[:pst]
    self.hst = tax_result[:hst]
    self.total = self.subtotal + self.gst + self.pst + self.hst
  end

  def calculate_subtotal
    order_items.sum(&:total_price)
  end

  private

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

  def calculate_taxes(province, subtotal)
    gst = subtotal * GST_RATE
    pst = PST_RATES[province] ? subtotal * PST_RATES[province] : 0
    hst = HST_RATES[province] ? subtotal * HST_RATES[province] : 0

    # Ensure that GST is set to 0 if HST is applicable
    gst = 0 if hst.positive?

    { gst: gst, pst: pst, hst: hst }
  end
end