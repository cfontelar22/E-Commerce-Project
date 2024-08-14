class AddTrackableToCustomers < ActiveRecord::Migration[7.1] 
  def change
    add_column :customers, :sign_in_count, :integer, default: 0, null: false
    add_index :customers, :sign_in_count
    add_column :customers, :current_sign_in_at, :datetime
    add_column :customers, :last_sign_in_at, :datetime
  end
end
