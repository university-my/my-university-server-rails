class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :server_id

      t.belongs_to :university, index: true, null: true

      t.timestamps
    end
  end
end
