class Category < ApplicationRecord
    has_many :products
  
    # Associations that are allowed to be searched by Ransack
    def self.ransackable_associations(auth_object = nil)
      %w[products] # This is assuming you want to allow Ransack to search categories by their products
    end
  
    # Attributes that are allowed to be searched by Ransack
    def self.ransackable_attributes(auth_object = nil)
      %w[id name] # Here you list the actual column names of the Category model you want to search by
    end
  
    # Attributes that will not be searchable
    def self.unransackable_attributes(auth_object = nil)
      %w[created_at updated_at]
    end
  end
  