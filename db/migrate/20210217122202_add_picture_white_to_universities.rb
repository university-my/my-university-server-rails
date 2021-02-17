class AddPictureWhiteToUniversities < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :picture_white, :string, default: ""
  end
end
