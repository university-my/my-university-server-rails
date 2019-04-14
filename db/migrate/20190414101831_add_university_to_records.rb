class AddUniversityToRecords < ActiveRecord::Migration[5.2]
  def change

    add_reference :records, :university, foreign_key: true
  end
end
