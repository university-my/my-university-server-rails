ActiveAdmin.register Building do

  permit_params :name, :description, :university_id

  # Filterable attributes on the index screen
  filter :name
  filter :university, if: proc { current_admin_user.is_admin? }
  filter :slug_uk, if: proc { current_admin_user.is_admin? }

  # Index
  index do
    column :name

    # University
    if current_admin_user.is_admin?
      column t('university') do |auditorium|
        link_to auditorium.university.short_name, admin_university_path(auditorium.university_id)
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
      f.input :description

      # University
      if current_admin_user.is_admin?
        f.input :university, as: :select, include_blank: false
      elsif current_admin_user.is_editor?
        f.input :university, as: :select, collection: [current_admin_user.university], include_blank: false
      end

    end
    f.actions
  end

  action_item :view, only: :show, priority: 0 do
    link_to t("active_admin.visit_on_site"), university_building_url(building.university.url, building.friendly_id)
  end

  # Show Page
  show do
    attributes_table do
      row :name
      row :description
      row :university
      row :created_at
      row :updated_at
    end
  end

end
