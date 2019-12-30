class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|

      t.string :name
      t.string :description, null: true
      t.integer :server_id, null: true

      t.belongs_to :university, index: true, null: true

      t.timestamps
    end
  end
end
