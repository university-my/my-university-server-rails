class AddSlugUkToFaculties < ActiveRecord::Migration[5.2]
  def change
    add_column :faculties, :slug_en, :string
    add_column :faculties, :slug_uk, :string
    add_index :faculties, :slug_en
    add_index :faculties, :slug_uk
  end
end
