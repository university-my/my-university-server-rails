require 'json'

module DisciplinesHelper

	# Export Discipline `name` and `visible_name` to file
	# For manual improvement of discipline names
	def self.export_disciplines_to_json
		disciplines_json = Discipline.all.order(:name).pluck(:name, :visible_name)
		File.open('exported_disciplines.json', 'w') { |file| file.write(disciplines_json) }
	end
end
