class AddSlugUkToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :slug_en, :string
    add_column :departments, :slug_uk, :string
    add_index :departments, :slug_en
    add_index :departments, :slug_uk
  end
end
