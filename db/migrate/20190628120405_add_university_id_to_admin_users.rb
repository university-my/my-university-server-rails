class AddUniversityIdToAdminUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :admin_users, :university_id, :integer
    add_index :admin_users, :university_id
  end
  
  def down
    remove_column :admin_users, :university_id
  end
end
