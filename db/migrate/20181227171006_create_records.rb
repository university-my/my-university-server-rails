class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|

      t.datetime :start_date
      t.string :name, null: true
      t.string :pair_name
      t.string :reason, null: true
      t.string :type, null: true
      t.string :time, null: true

      t.belongs_to :auditorium, index: true, null: true
      t.belongs_to :group, index: true, null: true
      t.belongs_to :teacher, index: true, null: true

      t.timestamps
    end
  end
end
