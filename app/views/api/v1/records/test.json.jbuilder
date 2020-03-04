json.records do
  json.partial! partial: 'records/record', collection: @records, as: :record
end
