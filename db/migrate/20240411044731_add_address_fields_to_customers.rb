class AddAddressFieldsToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :address, :string unless column_exists?(:customers, :address)
    add_column :customers, :city, :string unless column_exists?(:customers, :city)
    add_column :customers, :province, :string unless column_exists?(:customers, :province)
    add_column :customers, :postal_code, :string unless column_exists?(:customers, :postal_code)
  end
end
