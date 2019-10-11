class AddSlugUkToBuildings < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :slug_en, :string
    add_column :buildings, :slug_uk, :string
    add_index :buildings, :slug_en
    add_index :buildings, :slug_uk
  end
end
