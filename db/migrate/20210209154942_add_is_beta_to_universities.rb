class AddIsBetaToUniversities < ActiveRecord::Migration[5.2]
  def change
        add_column :universities, :is_beta, :boolean, :default => false
  end
end
