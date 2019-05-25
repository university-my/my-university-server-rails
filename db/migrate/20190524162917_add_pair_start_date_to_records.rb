class AddPairStartDateToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :pair_start_date, :datetime
  end
end
