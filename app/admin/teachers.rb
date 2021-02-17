ActiveAdmin.register Teacher do

  permit_params :name, :server_id, :university_id, :department_id, :is_hidden

  actions :all

  # Filterable attributes on the index screen
  filter :university, if: proc { current_admin_user.is_admin? }
  filter :slug_uk, if: proc { current_admin_user.is_admin? }
  filter :name
  filter :server_id, if: proc { current_admin_user.is_admin? }

  # Index
  index do
    # Other server
    if current_admin_user.is_admin?
      column :server_id
    end

    column :name

    if current_admin_user.is_admin?
      column :department
    end

    # Columns for admin
    if current_admin_user.is_admin?
      column t('university') do |teacher|
        link_to teacher.university.short_name, admin_university_path(teacher.university_id)
      end
      column :slug_uk
      column :created_at
      column :updated_at
      column :is_hidden
    end

    actions
  end

  # Form
  form do |f|
    f.inputs do
      f.input :name

      # University
      if current_admin_user.is_admin?
        f.input :university, as: :select, include_blank: false
      elsif current_admin_user.is_editor?
        f.input :university, as: :select, collection: [current_admin_user.university], include_blank: false
      end

      f.input :department, as: :select,
        collection: Department.where(university: current_admin_user.university)
                      .collect { |a| [ a.name, a.id ] }

      f.input :is_hidden
    end
    f.actions
  end

  action_item :view, only: :show, priority: 0 do
    link_to t("active_admin.visit_on_site"), university_teacher_url(teacher.university.url, teacher.friendly_id)
  end

  # Show Page
  show do
    attributes_table do
      row :name
      row :university
      row :created_at
      row :updated_at
      if current_admin_user.is_admin?
        row :lowercase_name
        row :department
      end
      row :is_hidden
    end
  end

end
