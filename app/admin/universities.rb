ActiveAdmin.register University do

  permit_params :short_name, :full_name, :url, :is_hidden, :is_beta, :website, :uid

  actions :index, :show, :edit, :update

  config.filters = false
  
  index do
    column :short_name
    column :full_name
    column :website
    column :uid
    actions
  end
end
