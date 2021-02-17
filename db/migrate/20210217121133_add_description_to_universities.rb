class AddDescriptionToUniversities < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :description, :text, default: ""
  end
end
