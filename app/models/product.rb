class Product < ApplicationRecord
    belongs_to :category
    has_one_attached :image
  
    # Attributes that are allowed to be searched by Ransack
    def self.ransackable_attributes(auth_object = nil)
      %w[name description price quantity created_at updated_at]
    end
  
    # Specify which associations can be used for searching
    def self.ransackable_associations(auth_object = nil)
      %w[category]
    end
  
    # Attributes that will not be searchable
    def self.unransackable_attributes(auth_object = nil)
      %w[id]
    end
  end
  