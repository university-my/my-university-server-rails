ActiveAdmin.register University do

  permit_params :short_name, :full_name, :url, :is_hidden, :is_beta

  actions :index, :show, :edit, :update

  config.filters = false
  
  index do
    column :short_name
    column :full_name
    actions
  end
end
