ActiveAdmin.register Group do

  permit_params :name, :server_id, :university_id
  
  actions :all
  
  # Filterable attributes on the index screen
  filter :university
  filter :name
  
  index do
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
        f.input :university, as: :select, include_blank: false
      elsif current_admin_user.is_kpi_editor? || current_admin_user.is_sumdu_editor?
        f.input :university, as: :select, collection: [current_admin_user.university], include_blank: false
      end
    end
    f.actions
  end

end
