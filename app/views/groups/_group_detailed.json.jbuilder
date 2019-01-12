json.group do
  json.extract! group, :id, :name  
end

json.records do
  json.partial! partial: 'records/record', collection: @group.records, as: :record
end