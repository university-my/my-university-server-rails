ActiveAdmin.register Teacher do
  permit_params :name, :server_id, :slug, :slug_en, :slug_uk, :university_id
  
  actions :index
  
  index do
    selectable_column
    id_column
    column :name
    column :server_id
    column :university_id
    column :created_at
    column :updated_at
    column :slug
    column :slug_en
    column :slug_uk
    actions
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :server_id
      f.input :university_id
      f.input :slug
      f.input :slug_en
      f.input :slug_uk
    end
    f.actions
  end

end
