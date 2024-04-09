ActiveAdmin.register Order do


  show do
    attributes_table do
      row :customer do |order|
        link_to order.customer.email, admin_customer_path(order.customer)
      end
      row :subtotal
      row :gst
      row :pst
      row :hst
      row :total
      row :address
      row :created_at
      row :updated_at
    end

    panel "Products" do
      table_for order.order_items.includes(:product) do
        column :product do |item|
          link_to item.product.name, admin_product_path(item.product)
        end
        column :quantity
        column :price
        column :total_price

      end
    end
  end

end
