class AddSlugToSpecialities < ActiveRecord::Migration[5.2]
  def change
    add_column :specialities, :slug, :string
    add_index :specialities, :slug
  end
end
