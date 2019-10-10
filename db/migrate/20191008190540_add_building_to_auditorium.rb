class AddBuildingToAuditorium < ActiveRecord::Migration[5.2]
  def change
    add_reference :auditoriums, :building, foreign_key: true, null: true
  end
end
