class AddIsHiddenToClassrooms < ActiveRecord::Migration[5.2]
  def change
    add_column :auditoriums, :is_hidden, :boolean, :default => false
    add_column :groups, :is_hidden, :boolean, :default => false
    add_column :teachers, :is_hidden, :boolean, :default => false
  end
end
