ActiveAdmin.register Discipline do

  permit_params :name, :university_id

  # Filterable attributes on the index screen
  filter :university
  filter :name

  index do
    column :name
    column :university
    actions
  end
end
