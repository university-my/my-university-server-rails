class AddPictureDarkToUniversities < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :picture_dark, :string, default: ""
  end
end
