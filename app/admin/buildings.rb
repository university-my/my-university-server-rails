ActiveAdmin.register Building do

  permit_params :name, :description, :university_id

  # Filterable attributes on the index screen
  filter :university
  filter :name

  index do
    column :name
    column :description
    column :university
    actions
  end
end
