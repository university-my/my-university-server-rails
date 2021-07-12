class CreateDisciplineNameSuggestions < ActiveRecord::Migration[5.2]
  def change
    create_table :discipline_name_suggestions do |t|
      t.string :name
      t.belongs_to :discipline, index: true, null: true

      t.timestamps
    end
  end
end
