class Category < ApplicationRecord
  has_many :products

  # Specify which associations can be used for searching with Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[products]
  end

  # Attributes that are allowed to be searched by Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[id name]
  end

  # Attributes that will not be searchable by Ransack
  def self.unransackable_attributes(auth_object = nil)
    []
  end
end
