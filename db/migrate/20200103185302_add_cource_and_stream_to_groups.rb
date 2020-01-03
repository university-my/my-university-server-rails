class AddCourceAndStreamToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :course, :integer, null: true
    add_column :groups, :stream, :integer, null: true
  end
end
