ActiveAdmin.register University do

  permit_params :short_name,
  :full_name,
  :url,
  :is_hidden,
  :is_beta,
  :website,
  :uid,
  :description,
  :picture_white,
  :picture_dark,
  :show_classrooms,
  :show_groups,
  :show_teachers,
  :show_disciplines

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
