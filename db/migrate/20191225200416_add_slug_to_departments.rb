class AddSlugToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :slug, :string
    add_index :departments, :slug
  end
end
