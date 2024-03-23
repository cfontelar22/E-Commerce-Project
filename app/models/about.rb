class About < ApplicationRecord

    # Whitelist attributes for Ransack search
  def self.ransackable_attributes(auth_object = nil)
    %w[content created_at updated_at]
  end

  def self.unransackable_attributes(auth_object = nil)
    ['id', 'some_other_attribute']
  end
end
