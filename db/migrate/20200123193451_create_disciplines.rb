class CreateDisciplines < ActiveRecord::Migration[5.2]
  def change
    create_table :disciplines do |t|

      t.string :name
      t.string :description, null: true

      t.belongs_to :university, index: true, null: true
    end

    create_table :auditoriums_disciplines, id: false do |t|
      t.belongs_to :auditorium
      t.belongs_to :discipline
    end

    create_table :disciplines_groups, id: false do |t|
      t.belongs_to :discipline
      t.belongs_to :group
    end

    create_table :disciplines_teachers, id: false do |t|
      t.belongs_to :discipline
      t.belongs_to :teacher
    end
  end
end
