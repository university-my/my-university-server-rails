class AddSlugUkToAuditoriums < ActiveRecord::Migration[5.2]
  def change
    add_column :auditoriums, :slug_en, :string
    add_column :auditoriums, :slug_uk, :string
    add_index :auditoriums, :slug_en
    add_index :auditoriums, :slug_uk
  end
end
