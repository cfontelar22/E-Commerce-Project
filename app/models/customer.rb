class Customer < ApplicationRecord
    has_many :orders

  # Add validations for your customer details
  validates :first_name, :last_name, :address, :city, :province, :postal_code, :email, :phone_number, presence: true
  
  # Validate that the postal_code is present
  validates :postal_code, presence: true
end

