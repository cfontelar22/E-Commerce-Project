class AddPostalCodeToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :postal_code, :string
  end
end
