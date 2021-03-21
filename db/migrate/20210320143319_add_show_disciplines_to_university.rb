class AddShowDisciplinesToUniversity < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :show_disciplines, :boolean, :default => false
  end
end
