ActiveAdmin.register DisciplineNameSuggestion do

  permit_params :name, :discipline_id

  # Filterable attributes on the index screen
  filter :name
  filter :discipline

  # Index
  index do
    column :name
    column :discipline

    actions
  end

end
