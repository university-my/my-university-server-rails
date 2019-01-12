json.group do
  json.extract! auditorium, :id, :name  
end

json.records do
  json.partial! partial: 'records/record', collection: @auditorium.records, as: :record
end