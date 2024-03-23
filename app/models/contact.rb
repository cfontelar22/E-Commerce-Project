class Contact < ApplicationRecord
    # Only allow these attributes to be searchable by Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[content created_at updated_at]
  end

  # Exclude all other attributes from being searchable by Ransack
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
