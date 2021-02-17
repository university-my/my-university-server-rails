class AddShowClassroomToUniversities < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :show_classrooms, :boolean, :default => true
    add_column :universities, :show_groups, :boolean, :default => true
    add_column :universities, :show_teachers, :boolean, :default => true
  end
end
