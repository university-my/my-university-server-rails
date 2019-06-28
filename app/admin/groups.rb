ActiveAdmin.register Group do

  permit_params :name, :server_id, :university_id
  
  actions :all
  
  # Filterable attributes on the index screen
  filter :university
  filter :name
  
  index do
    selectable_column
    column :name
    column t('university') do |group|
      link_to group.university.short_name, admin_university_path(group.university_id)
    end
    actions
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :server_id
      if current_admin_user.is_admin?
        f.input :university_id
      end
    end
    f.actions
  end

end
