json.group do
  json.extract! teacher, :id, :name  
end

json.records do
  json.partial! partial: 'records/record', collection: @teacher.records, as: :record
end