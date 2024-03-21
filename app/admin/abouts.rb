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

controller do
  def create
    if About.count.zero? || Contact.count.zero?
      super
    else
      redirect_to collection_path, notice: 'Already created. You can only edit the existing one.'
    end
  end
end