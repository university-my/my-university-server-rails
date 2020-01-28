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

    create_table :groups_disciplines, id: false do |t|
      t.belongs_to :group
      t.belongs_to :discipline
    end

    create_table :teachers_disciplines, id: false do |t|
      t.belongs_to :teacher
      t.belongs_to :discipline
    end
  end
end
