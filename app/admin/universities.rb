ActiveAdmin.register University do

  actions :index, :show

  config.filters = false
  
  index do
    column :short_name
    column :full_name
    actions
  end
end
