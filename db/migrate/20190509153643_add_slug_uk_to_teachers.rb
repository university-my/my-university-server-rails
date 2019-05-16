class AddSlugUkToTeachers < ActiveRecord::Migration[5.2]
  def change
    add_column :teachers, :slug_en, :string
    add_column :teachers, :slug_uk, :string
    add_index :teachers, :slug_en
    add_index :teachers, :slug_uk
  end
end
