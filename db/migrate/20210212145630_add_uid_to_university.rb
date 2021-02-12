class AddUidToUniversity < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :uid, :integer, default: 0
  end
end
