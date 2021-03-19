class AddSlugUkToDisciplines < ActiveRecord::Migration[5.2]
  def change
    add_column :disciplines, :slug_en, :string
    add_column :disciplines, :slug_uk, :string
    add_index :disciplines, :slug_en
    add_index :disciplines, :slug_uk
  end
end
