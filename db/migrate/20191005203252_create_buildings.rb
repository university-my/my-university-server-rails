class CreateBuildings < ActiveRecord::Migration[5.2]
  def change
    create_table :buildings do |t|

      t.string :name
      t.string :description, null: true

      t.belongs_to :university, index: true, null: true

      t.timestamps
    end
  end
end
