ActiveAdmin.register University do

  actions :index, :show

  config.filters = false
  
  index do
    selectable_column
    column :short_name
    column :full_name
    actions
  end
end
