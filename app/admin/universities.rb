ActiveAdmin.register University do
  permit_params :short_name, :full_name, :url
  actions :index
  
  index do
    selectable_column
    id_column
    column :short_name
    column :full_name
    column :url
    column :created_at
    column :updated_at
    actions
  end
  
  form do |f|
    f.inputs do
      f.input :short_name
      f.input :full_name
      f.input :url
    end
    f.actions
  end

end
