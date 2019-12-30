class CreateFaculties < ActiveRecord::Migration[5.2]
  def change
    create_table :faculties do |t|

      t.string :name
      t.integer :server_id, null: true

      t.belongs_to :university, index: true, null: true

      t.timestamps
    end
  end
end
