class CreateUniversities < ActiveRecord::Migration[5.2]
  def change
    create_table :universities do |t|
      t.string :short_name
      t.string :full_name
      t.string :url

      t.timestamps
    end
  end
end
