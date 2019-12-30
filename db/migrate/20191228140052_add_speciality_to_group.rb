class AddSpecialityToGroup < ActiveRecord::Migration[5.2]
  def change
    add_reference :groups, :speciality, foreign_key: true, null: true
  end
end
