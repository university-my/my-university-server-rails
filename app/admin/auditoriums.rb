ActiveAdmin.register Auditorium do

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
    
    column t('university') do |auditorium|
      link_to auditorium.university.short_name, admin_university_path(auditorium.university_id)
    end

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
