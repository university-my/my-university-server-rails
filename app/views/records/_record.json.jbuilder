json.id record.id
json.name record.name
json.pair_start_date record.pair_start_date
json.start_date record.pair_start_date
json.pair_name record.pair_name
json.reason record.reason
json.kind record.kind
json.time record.time
json.discipline record.discipline

if record.auditorium.present?
	json.auditorium do
		json.partial! 'auditoriums/auditorium', auditorium: record.auditorium
	end
end

json.groups do
	json.partial! partial: 'groups/group', collection: record.groups, as: :group
end

if record.teacher.present?
	json.teacher do
		json.partial! 'teachers/teacher', teacher: record.teacher
	end
end
