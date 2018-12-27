class CreateAuditoriums < ActiveRecord::Migration[5.2]
  def change
    create_table :auditoriums do |t|
      t.string :name
      t.integer :server_id

      t.timestamps
    end
  end
end
