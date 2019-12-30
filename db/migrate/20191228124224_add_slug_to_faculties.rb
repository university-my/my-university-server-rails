class AddSlugToFaculties < ActiveRecord::Migration[5.2]
  def change
    add_column :faculties, :slug, :string
    add_index :faculties, :slug
  end
end
