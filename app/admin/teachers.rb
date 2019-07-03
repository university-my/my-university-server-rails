ActiveAdmin.register Teacher do

  permit_params :name, :server_id, :university_id
  
  actions :all

  # Filterable attributes on the index screen
  filter :university
  filter :name
  
  index do
    column :name

    column t('university') do |teacher|
      link_to teacher.university.short_name, admin_university_path(teacher.university_id)
    end
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
