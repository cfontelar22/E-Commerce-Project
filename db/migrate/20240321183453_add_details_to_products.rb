class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :weight, :integer
    add_column :products, :roast_level, :integer
    add_column :products, :flavor_profile, :text
    add_column :products, :grind_option, :text
  end
end
