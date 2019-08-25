class AddIsHiddenToUniversities < ActiveRecord::Migration[5.2]
  def up
    add_column :universities, :is_hidden, :boolean, :default => false
  end
  
  def down
    remove_column :universities, :is_hidden
  end
end
