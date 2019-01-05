require 'net/http'
require 'json'

class Auditorium < ApplicationRecord
  self.table_name = "auditoriums"

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_many :records, dependent: :nullify
  belongs_to :university, optional: true

  # Import for SumDU
  # # bin/rails runner 'Auditorium.importSumDU'
  def self.importSumDU

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

    # This groups for SumDU
    university = University.find_by(url: "sumdu")

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        auditoriumName = object[1]

        # Save new auditorium
        auditorium = Auditorium.new
        auditorium.server_id = serverID
        auditorium.name = auditoriumName
        auditorium.university = university

        unless auditorium.save
           # Go to the next iteration if can't be saved
           logger.error(auditorium.errors.full_messages)
           next
         end
        
      rescue Exception => e
        logger.error(e)
        next
      end

    end
  end

  # bin/rails runner 'Auditorium.resetUpdateDate'
  def self.resetUpdateDate
    Auditorium.update_all(updated_at: DateTime.current - 2.hour)
  end

  # Import records for current Auditorium
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

    # Delete old records
    Record.where('auditorium_id': id).where("updated_at < ?", DateTime.current - 2.day).destroy_all

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
        # Split groups into array
        groupNames = nameGroup.split(',')

        # Groups
        stripedNames = Array.new
        for groupName in groupNames do
          stripedNames.push(groupName.strip)
        end
        groups = Group.where(name: stripedNames)

        # Auditorium
        # Convert to int before find request
        teacherID = kodFio.to_i
        teacher = Teacher.where(server_id: teacherID).first

        # Pair start date
        startDate = dateString.to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:start_date] = startDate
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:kind] = kind
        conditions[:time] = time
        conditions[:auditorium] = self

        # Try to find existing record first
        record = Record.find_by(conditions)

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
           record.groups = groups
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

    # Update `updated_at` date of Auditorium
    touch(:updated_at)
    unless save
      logger.error(errors.full_messages)
    end
  end

   # Check if need to update records in the Auditorium
  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
  end

end
