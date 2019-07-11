class AddRoleToAdminUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :admin_users, :role, :string, null: false, default: 'reader'
  end
  
  def down
    remove_column :admin_users, :role
  end
end
