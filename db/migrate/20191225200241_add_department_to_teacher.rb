class AddDepartmentToTeacher < ActiveRecord::Migration[5.2]
  def change
    add_reference :teachers, :department, foreign_key: true, null: true
  end
end
