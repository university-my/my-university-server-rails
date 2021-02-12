class AddWebsiteToUniversity < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :website, :string, default: ""
  end
end
