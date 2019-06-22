ActiveAdmin.register Group do
  menu label: "Групи"

  permit_params :name, :server_id, :university_id
  
  actions :all
  
  # Filterable attributes on the index screen
  filter :university
  filter :name
  filter :created_at
  filter :updated_at
  
  index do
    selectable_column
    column :name
    column :university_id
    column :created_at
    column :updated_at
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
