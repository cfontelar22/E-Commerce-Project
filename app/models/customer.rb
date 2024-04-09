class Customer < ApplicationRecord
  # Associations
  has_many :orders, dependent: :destroy
  # Ensure a dependent: :destroy is set to handle the case when a Customer is deleted.

  # Validations
  validates :first_name, :last_name, :address, :city, :province, :postal_code, :email, :phone_number, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, format: { with: /\A(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}\z/ }
  validates :postal_code, format: { with: /\A[a-zA-Z0-9 ]+\z/ }

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

  # Add any custom methods or callbacks needed by your application here

end
