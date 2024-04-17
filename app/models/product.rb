class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image
  scope :featured, -> { where(featured: true) }
  scope :on_sale, -> { where(on_sale: true) }
  scope :newly_added, -> { where('created_at >= ?', 3.days.ago) }
  scope :recently_updated, -> { where('updated_at >= ?', 3.days.ago).where.not(id: newly_added.select(:id)) }
  has_many :order_items

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :image_attached

  def image_attached
    errors.add(:image, "must be attached") unless image.attached?
  end

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
