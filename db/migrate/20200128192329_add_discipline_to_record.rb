class AddDisciplineToRecord < ActiveRecord::Migration[5.2]
  def change
    add_reference :records, :discipline, foreign_key: true, null: true
  end
end
