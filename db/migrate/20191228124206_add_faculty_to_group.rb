class AddFacultyToGroup < ActiveRecord::Migration[5.2]
  def change
    add_reference :groups, :faculty, foreign_key: true, null: true
  end
end
