ActiveAdmin.register Product do
  permit_params :name, :description, :price, :quantity, :category_id, :image

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :price
    column :quantity
    column :category
    column 'Image' do |product|
      if product.image.attached?
        image_tag url_for(product.image), width: '50px' # Ensure 'px' is specified
      else
        'No image'
      end
    end
    actions
  end

  filter :name
  filter :price
  filter :quantity
  filter :category, as: :select, collection: -> { Category.all }

  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :quantity
      row :category
      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image), width: '50%' # Ensure 'px' is specified if needed
        else
          'No image'
        end
      end
    end
    active_admin_comments
  end
  form html: { enctype: "multipart/form-data" } do |f|
    f.inputs 'Product Details' do
      f.input :name
      f.input :description
      f.input :price
      f.input :quantity
      f.input :category, as: :select, collection: Category.all.collect { |c| [c.name, c.id] }
      if f.object.persisted? && f.object.image.attached?
        f.input :image, as: :file, hint: image_tag(url_for(f.object.image), width: '150x')
      else
        f.input :image, as: :file
      end
    end
    f.actions
  end
end 