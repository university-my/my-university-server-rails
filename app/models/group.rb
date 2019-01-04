require 'net/http'
require 'json'

class Group < ApplicationRecord

  # Fields validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_and_belongs_to_many :records, optional: true, dependent: :nullify
  belongs_to :university, optional: true

  # Import for SumDU
  # bin/rails runner 'Group.importSumDU'
  def self.importSumDU

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getGroups")
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
    Group.destroy_all

    # This groups for SumDU
    university = University.find_by(name: "SumDU")

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        groupName = object[1]

        # Save new group
        group = Group.new
        group.server_id = serverID
        group.name = groupName
        group.university = university
        
        unless group.save
           # Go to the next iteration if can't be saved
           logger.error(group.errors.full_messages)
           next
         end

       rescue Exception => e
        logger.error(e)
        next
      end

    end
  end

  # bin/rails runner 'Group.resetUpdateDate'
  def self.resetUpdateDate
    Group.update_all(updated_at: DateTime.current - 2.hour)
  end

  # Import records for current Group
  def importRecords
    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_grp=#{server_id}"

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
    Record.joins(:groups).where('groups.id': id).where("records.updated_at < ?", DateTime.current - 2.day).destroy_all

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

      # Teacher
      kodFio = object['KOD_FIO']

      begin
        # Convert to int before find request

        # Auditorium
        auditoriumID = kodAud.to_i
        auditorium = Auditorium.find_by(server_id: auditoriumID)

        # Teacher
        teacherID = kodFio.to_i
        teacher = Teacher.find_by(server_id: teacherID)

        # Pair start date
        startDate = dateString.to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:start_date] = startDate
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:kind] = kind
        conditions[:time] = time

        # Try to find existing record first
        record = Record.joins(:groups).where('groups.id': id).first

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
           record.groups = [self]
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

    # Update `updated_at` date of Group
    touch(:updated_at)
    unless save
      logger.error(errors.full_messages)
    end
  end

  # Check if need to update records in the Group
  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
  end

end
