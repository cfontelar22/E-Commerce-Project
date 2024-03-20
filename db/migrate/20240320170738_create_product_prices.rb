class CreateProductPrices < ActiveRecord::Migration[7.1]
  def change
    create_table :product_prices do |t|
      t.references :product, null: false, foreign_key: true
      t.decimal :price
      t.datetime :effective_date

      t.timestamps
    end
  end
end
