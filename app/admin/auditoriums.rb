ActiveAdmin.register Auditorium do

  permit_params :name, :server_id, :university_id
  
  actions :all

  # Filterable attributes on the index screen
  filter :university
  filter :name
  
  index do
    selectable_column
    column :name
    
    column t('university') do |auditorium|
      link_to auditorium.university.short_name, admin_university_path(auditorium.university_id)
    end

    actions
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :university
    end
    f.actions
  end

end
