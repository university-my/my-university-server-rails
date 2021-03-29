ActiveAdmin.register Discipline do

  permit_params :name, :university_id, :visible_name

  # Filterable attributes on the index screen
  filter :name
  filter :visible_name
  filter :university, if: proc { current_admin_user.is_admin? }
  filter :slug_uk, if: proc { current_admin_user.is_admin? }

  # Index
  index do
    column :name
    column :visible_name

    # University
    if current_admin_user.is_admin?
      column t('university') do |discipline|
        if discipline.university
          link_to discipline.university.short_name, admin_university_path(discipline.university_id)
        end
      end
    end

    # Columns for admin
    if current_admin_user.is_admin?
      column :slug_uk
      column :created_at
      column :updated_at
    end

    actions
  end

  # Form
  form do |f|
    f.inputs do
      f.input :name
      f.input :visible_name

      # University
      if current_admin_user.is_admin?
        f.input :university, as: :select, include_blank: false
      elsif current_admin_user.is_editor?
        f.input :university, as: :select, collection: [current_admin_user.university], include_blank: false
      end
    end
    f.actions
  end

  # Show Page
  show do
    attributes_table do
      row :name
      row :visible_name
      row :university
      row :created_at
      row :updated_at
    end
  end

end
