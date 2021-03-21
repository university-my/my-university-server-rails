class AddVisibleNameToDisciplines < ActiveRecord::Migration[5.2]
  def change
    add_column :disciplines, :visible_name, :string, default: ""
  end
end
