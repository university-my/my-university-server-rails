ActiveAdmin.register AdminUser do

  permit_params :email, :password, :password_confirmation, :role, :university_id

  index do
    column :email
    column :role
    column :university
    column :created_at
    actions
  end

  config.filters = false

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: AdminUser::ADMIN_ROLES, include_blank: false
      f.input :university
    end
    f.actions
  end

end
