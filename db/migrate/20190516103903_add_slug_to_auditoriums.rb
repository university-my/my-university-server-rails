class AddSlugToAuditoriums < ActiveRecord::Migration[5.2]
  def change
    add_column :auditoriums, :slug, :string
    add_index :auditoriums, :slug
  end
end
