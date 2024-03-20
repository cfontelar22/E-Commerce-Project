class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  # Only allow searching by these attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at]
  end

  # Exclude sensitive or unnecessary attributes from being searchable
  def self.unransackable_attributes(auth_object = nil)
    %w[encrypted_password reset_password_token reset_password_sent_at remember_created_at]
  end
end
