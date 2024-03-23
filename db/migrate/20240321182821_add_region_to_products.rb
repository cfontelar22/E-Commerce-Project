class AddRegionToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :region, :string
  end
end
