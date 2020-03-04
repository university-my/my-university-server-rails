class RemoveStartDateFromRecord < ActiveRecord::Migration[5.2]
  def change
    remove_column :records, :start_date
  end
end
