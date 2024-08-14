ActiveAdmin.register Customer do
  filter :phone_number_cont
  
  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :address
    column :city
    column :province
    column :postal_code
    column :phone_number
    column :created_at
    column :updated_at
    actions
  end
end
  