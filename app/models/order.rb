class Order < ApplicationRecord
  belongs_to :customer
  accepts_nested_attributes_for :customer

  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, reject_if: proc { |attributes| attributes['product_id'].blank? }

  enum status: { pending: 'pending', paid: 'paid', shipped: 'shipped', cancelled: 'cancelled' }

  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :order_items, presence: true
  validate :valid_status_transition, on: :update

  before_save :set_taxes_and_total

  def self.ransackable_attributes(auth_object = nil)
    %w[address created_at customer_id gst hst id id_value pst subtotal total updated_at]
  end

  private

  GST_RATE = 0.05
  PST_RATES = {
    'BC' => 0.07,
    'MB' => 0.07,
    'SK' => 0.06,
  }
  HST_RATES = {
    'NL' => 0.15,
    'NB' => 0.15,
    'NS' => 0.15,
    'PE' => 0.15,
    'ON' => 0.13,
  }

  def calculate_subtotal
    order_items.sum(&:total_price)
  end

  def calculate_taxes(province, subtotal)
    gst = subtotal * GST_RATE
    pst = PST_RATES[province] || 0
    hst = HST_RATES[province] || 0
    gst = 0 if hst.positive?
    { gst: gst, pst: pst, hst: hst }
  end

  def set_taxes_and_total
    self.subtotal = calculate_subtotal
    tax_result = calculate_taxes(customer.province, subtotal)
    self.gst = tax_result[:gst]
    self.pst = tax_result[:pst]
    self.hst = tax_result[:hst]
    self.total = self.subtotal + self.gst + self.pst + self.hst
  end

  def valid_status_transition
    return if status_was == 'cancelled' # Assume once cancelled, status cannot change
    errors.add(:status, 'invalid transition') if status_was == 'shipped' && status == 'pending'
  end
end
