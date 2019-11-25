class AddLowercaseNameToTeachers < ActiveRecord::Migration[5.2]
  def up
    add_column :teachers, :lowercase_name, :string, null: true
  end

  def down
    remove_column :teachers, :lowercase_name
  end
end
