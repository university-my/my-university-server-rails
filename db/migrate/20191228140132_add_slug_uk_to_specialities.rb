class AddSlugUkToSpecialities < ActiveRecord::Migration[5.2]
  def change
    add_column :specialities, :slug_en, :string
    add_column :specialities, :slug_uk, :string
    add_index :specialities, :slug_en
    add_index :specialities, :slug_uk
  end
end
