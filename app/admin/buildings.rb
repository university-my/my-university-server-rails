ActiveAdmin.register Building do

  permit_params :name, :description, :university_id

  # Filterable attributes on the index screen
  filter :university
  filter :name

  index do
    column :name
    column :description

    column t('university') do |building|
      link_to building.university.short_name, admin_university_path(building.university_id)
    end

    actions
  end
end
