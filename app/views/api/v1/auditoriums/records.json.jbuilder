json.auditorium do
  json.extract! @auditorium, :id, :name
end

json.records do
  json.partial! partial: 'records/record', collection: @records, as: :record
end
