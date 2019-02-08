json.extract! record, :id, :name, :start_date, :pair_name, :reason, :kind, :time

if json.auditorium.present?
	json.auditorium do
		json.partial! 'auditoriums/auditorium', auditorium: record.auditorium
	end
end

json.groups do
	json.partial! partial: 'groups/group', collection: record.groups, as: :group
end