ActiveAdmin.register Category do
  permit_params :name 
  filter :name
  filter :products_name, as: :string 


  index do
    selectable_column
    id_column
    column :name
    column "Products" do |category|
      category.products.count 
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
      row "Products" do |category|
        ul do
          category.products.each do |product|
            li link_to(product.name, admin_product_path(product))
          end
        end
      end
    end
  end

  form do |f|
    f.inputs 'Category Details' do
      f.input :name
    end
    f.actions
  end
end
