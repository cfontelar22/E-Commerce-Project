class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :orders, dependent: :destroy

  # Validations
  validates_presence_of :province

  # Ransack scopes
  scope :with_orders, -> { joins(:orders).distinct }

  def self.ransackable_scopes(auth_object = nil)
    %i[with_orders]
  end

  # Ransack configuration for searchable associations
  def self.ransackable_associations(auth_object = nil)
    %w[orders]
  end

  # Ransack configuration for searchable attributes
  # Explicitly define searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[first_name last_name address city province postal_code email phone_number]
  end
end
