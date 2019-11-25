class AddLowercaseNameToGroups < ActiveRecord::Migration[5.2]
  def up
    add_column :groups, :lowercase_name, :string, null: true
  end

  def down
    remove_column :groups, :lowercase_name
  end
end
