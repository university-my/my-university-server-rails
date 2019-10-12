class AddSlugToBuildings < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :slug, :string
    add_index :buildings, :slug
  end
end
