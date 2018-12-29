require 'net/http'
require 'json'

class Auditorium < ApplicationRecord
  self.table_name = "auditoriums"

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_many :records

  # Import for SumDU
  # # bin/rails runner 'Auditorium.importSumDU'
  def self.importSumDU

    logger.info "Start import SumDU auditoriums"

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getAuditoriums")
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    # Delete before save
    Auditorium.destroy_all

    for object in json do
      serverID = Integer(object[0])
      auditoriumName = object[1]

      # Save new auditorium
      auditorium = Auditorium.new
      auditorium.server_id = serverID
      auditorium.name = auditoriumName
      auditorium.save
    end
  end

  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    # Check by records
    if records.empty?
      needToUpdate = true
    end

    return needToUpdate
  end

  def importRecords
    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_aud=#{server_id}"

    # Init URI
    uri = URI(url + query)
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    # Save records
    for object in json do

      # Get data from JSON
      dateString = object['DATE_REG']
      time = object['TIME_PAIR']
      pairName = object['NAME_PAIR']
      nameString = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Teacher
      kodFio = object['KOD_FIO']

      # Group
      nameGroup = object['NAME_GROUP']

      begin
        # Convert to int before find request
        teacherID = kodFio.to_i
        teacher = Teacher.where(server_id: teacherID).first

        group = Group.where(name: nameGroup).first

        startDate = dateString.to_datetime

        conditions = {}
        conditions[:start_date] = startDate
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:kind] = kind
        conditions[:time] = time
        conditions[:auditorium] = self

        unless teacher.nil?
          conditions[:teacher] = teacher
        end

        unless group.nil?
          conditions[:group] = group
        end

        # Try to find existing record first
        record = Record.where(conditions).first

        if record.nil?
           # Save new record
           record = Record.new
           record.start_date = startDate
           record.time = time
           record.pair_name = pairName
           record.name = nameString
           record.reason = reason
           record.kind = kind

           # Associations
           record.auditorium = self
           record.group = group
           record.teacher = teacher

           unless record.save
           # Go to the next iteration if record can't be saved
           logger.error(record.errors.full_messages)
           next
           end
         end
        
      rescue Exception => e
        logger.error(e)
        next
      end
    end
  end

end
