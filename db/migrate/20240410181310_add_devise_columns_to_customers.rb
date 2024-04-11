class AddDeviseColumnsToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :encrypted_password, :string
  end
end
