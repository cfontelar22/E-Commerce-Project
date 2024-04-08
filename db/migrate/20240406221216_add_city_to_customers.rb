class AddCityToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :city, :string
  end
end

