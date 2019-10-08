class AddServerIdToBuilding < ActiveRecord::Migration[5.2]
  def up
    add_column :buildings, :server_id, :integer, null: true
  end

  def down
    remove_column :buildings, :server_id
  end
end
