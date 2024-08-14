class RenameUserIdToCustomerIdInOrders < ActiveRecord::Migration[6.0]
  def change
    # If your customer table is indeed called `customers` and not `users`
    remove_foreign_key :orders, :users if foreign_key_exists?(:orders, :users)
    rename_column :orders, :user_id, :customer_id if column_exists?(:orders, :user_id)
    add_foreign_key :orders, :customers if table_exists?(:customers)
  end
end
