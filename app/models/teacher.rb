require 'net/http'
require 'json'

class Teacher < ApplicationRecord

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { greater_than: 0 }, uniqueness: true

  # Associations
  has_many :records
  belongs_to :university, optional: true

  # Import for SumDU
  # bin/rails runner 'Teacher.importSumDU'
  def self.importSumDU
    
    logger.info "Start import SumDU techers"

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

    university = University.find_by(name: "SumDU")

    # Delete before save
    Teacher.destroy_all

    for object in json do
      serverID = Integer(object[0])
      teacherName = object[1]

      # Save new teacher
      teacher = Teacher.new
      teacher.server_id = serverID
      teacher.name = teacherName
      teacher.university = university
      teacher.save
    end
  end

  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
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
        # Convert to int before find request
        auditoriumID = kodAud.to_i
        auditorium = Auditorium.where(server_id: auditoriumID).first

        group = Group.where(name: nameGroup).first

        startDate = dateString.to_datetime

        conditions = {}
        conditions[:start_date] = startDate
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:kind] = kind
        conditions[:time] = time
        conditions[:teacher] = self

        unless auditorium.nil?
          conditions[:auditorium] = auditorium
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
           record.auditorium = auditorium
           record.group = group
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

end
