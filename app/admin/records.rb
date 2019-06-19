ActiveAdmin.register Record do
  permit_params :start_date, :name, :pair_name, :created_at, :updated_at, :reason, :kind, :time, :university_id, :auditorium_id, :teacher_id, :pair_start_date
  
  actions :index
  
  index do
    selectable_column
    id_column
    column :start_date
    column :name
    column :pair_name
    column :university_id
    column :created_at
    column :updated_at
    column :reason
    column :kind
    column :time
    column :auditorium_id
    column :teacher_id
    column :pair_start_date
    actions
  end
  
  form do |f|
    f.inputs do
      f.input :start_date
      f.input :name
      f.input :pair_name
      f.input :university_id
      f.input :reason
      f.input :kind
      f.input :time
      f.input :auditorium_id
      f.input :teacher_id
      f.input :pair_start_date
    end
    f.actions
  end

end
