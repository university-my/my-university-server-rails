require 'net/http'
require 'json'

class Teacher < ApplicationRecord

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { greater_than: 0 }, uniqueness: true

  # Associations
  has_many :records, dependent: :nullify
  belongs_to :university, optional: true

  # Import for SumDU
  # bin/rails runner 'Teacher.importSumDU'
  def self.importSumDU

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getTeachers")
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

    # This groups for SumDU
    university = University.find_by(url: "sumdu")

    # Delete before save
    Teacher.destroy_all

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        teacherName = object[1]

        # Save new teacher
        teacher = Teacher.new
        teacher.server_id = serverID
        teacher.name = teacherName
        teacher.university = university

        unless teacher.save
           # Go to the next iteration if can't be saved
           logger.error(teacher.errors.full_messages)
           next
         end

      rescue Exception => e
        logger.error(e)
        next
      end

    end
  end

  # bin/rails runner 'Teacher.resetUpdateDate'
  def self.resetUpdateDate
    Teacher.update_all(updated_at: DateTime.current - 2.hour)
  end

def importRecords
    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_fio=#{server_id}"

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
    Record.where('teacher_id': id).where("updated_at < ?", DateTime.current - 2.day).destroy_all

    # Save records
    for object in json do

      # Get data from JSON
      dateString = object['DATE_REG']
      time = object['TIME_PAIR']
      pairName = object['NAME_PAIR']
      nameString = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Auditorium
      kodAud = object['KOD_AUD']

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
        auditoriumID = kodAud.to_i
        auditorium = Auditorium.where(server_id: auditoriumID).first

        # Pair start date
        startDate = dateString.to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:start_date] = startDate
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:kind] = kind
        conditions[:time] = time
        conditions[:teacher] = self

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
           record.auditorium = auditorium
           record.groups = groups
           record.teacher = self

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

    # Update `updated_at` date of Teacher
    touch(:updated_at)
    unless save
      logger.error(errors.full_messages)
    end
  end

  # Check if need to update records in the Teacher
  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
  end

end
