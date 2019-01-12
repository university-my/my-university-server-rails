json.extract! record, :id, :name, :start_date, :pair_name, :reason, :kind, :time, :auditorium_id, :teacher_id

json.groups do
  json.partial! partial: 'groups/group', collection: record.groups, as: :group
end