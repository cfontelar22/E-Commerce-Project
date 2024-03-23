ActiveAdmin.register About do
  permit_params :content

  form do |f|
    f.inputs 'About Page Details' do
      f.input :content, as: :text
    end
    f.actions
  end

  show do
    attributes_table do
      row :content
    end
  end
end
