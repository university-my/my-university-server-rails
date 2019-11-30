class AddLowercaseNameToAuditorium < ActiveRecord::Migration[5.2]
  def up
    add_column :auditoriums, :lowercase_name, :string, null: true
  end

  def down
    remove_column :auditoriums, :lowercase_name
  end
end
