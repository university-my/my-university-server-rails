ActiveAdmin.register Auditorium do
  permit_params :name, :server_id, :university_id
  
  actions :all

  # Filterable attributes on the index screen
  filter :university
  filter :name
  filter :server_id
  filter :created_at
  filter :updated_at
  filter :slug_uk
  
  index do
    selectable_column
    id_column
    column :name
    column :server_id
    column :university_id
    column :created_at
    column :updated_at
    column :slug_uk
    actions
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :server_id
      f.input :university_id
    end
    f.actions
  end

end
