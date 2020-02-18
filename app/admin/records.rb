ActiveAdmin.register Record do

  permit_params :start_date, :name, :pair_name, :created_at, :updated_at, :reason, :kind, :time, :auditorium_id, :teacher_id, :pair_start_date

  actions :all

  # Filterable attributes on the index screen
  filter :name

  filter :auditorium, collection: proc { Auditorium.where(university: current_admin_user.university).all }
  filter :group, collection: proc { Group.where(university: current_admin_user.university).all }
  filter :teacher, collection: proc { Teacher.where(university: current_admin_user.university).all }
  filter :university, if: proc { current_admin_user.is_admin? }
  filter :discipline, collection: proc { Discipline.where(university: current_admin_user.university).all }

  # Index
  index do
    selectable_column
    column :pair_start_date
    column :discipline

    # University
    if current_admin_user.is_admin?
      column t('university') do |record|
        if record.university
          link_to record.university.short_name, admin_university_path(record.university_id)
        end
      end
    end

    column :reason
    column :kind
    column :auditorium
    column :teacher

    actions
  end

  # Form
  form do |f|
    f.inputs do

      f.input :discipline, as: :select,
      collection: Discipline.where(university: current_admin_user.university)
      .collect { |a| [ a.name, a.id ] }

      f.input :start_date

      f.input :reason
      f.input :kind
      f.input :auditorium, as: :select,
      collection: Auditorium.where(university: current_admin_user.university)
      .collect { |a| [ a.name, a.id ] }
      f.input :teacher, as: :select,
      collection: Teacher.where(university: current_admin_user.university)
      .collect { |a| [ a.name, a.id ] }
    end
    f.actions
  end

end
