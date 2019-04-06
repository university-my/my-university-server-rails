require 'net/http'
require 'json'

class Group < ApplicationRecord

  # Fields validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_and_belongs_to_many :records, optional: true, dependent: :nullify
  belongs_to :university, optional: true

  # Make request to API for get total count of all groups
  def self.getGroupsCountForKPI
    # Init URI
    uri = URI("https://api.rozklad.org.ua/v2/groups")
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

    totalCount = json["meta"]["total_count"]
    teachersTotalCount = Integer(totalCount)

    return teachersTotalCount
  end

  # Make request with offset parameter and parse JSON
  def self.getGroupsForKPI(offset)
     # Init URI
     uri = URI("https://api.rozklad.org.ua/v2/groups/?filter={%27limit%27:100,%27offset%27:#{offset}}")
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

    return json
  end

  def self.saveGroupsFrom(json)

    data = json["data"]

    # This groups for SumDU
    university = University.find_by(url: "kpi")
    
    for object in data do

      begin

        # Convert before save
        serverID = Integer(object["group_id"])
        groupName = String(object["group_full_name"])

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

  # Import for KPI
  # bin/rails runner 'Group.importKPI'
  def self.importKPI
    groupsTotalCount = getGroupsCountForKPI

    # This groups for KPI
    university = University.find_by(url: "kpi")

    # Delete before save
    Group.where(university_id: university.id).destroy_all

    offset = 0

    while offset < groupsTotalCount
      # Get json with groups from API
      json = getGroupsForKPI(offset)

      # Save to database
      saveGroupsFrom(json)

      offset += 100
    end
  end

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

    # This groups for SumDU
    university = University.find_by(url: "sumdu")

    # Delete before save
    Group.where(university_id: university.id).destroy_all

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
    if university.url == "sumdu"
      importRecordsForSumDU  
    end

    if university.url == "kpi"
      importRecordsForKPI
    end
  end

  def importRecordsForKPI
    # Update `updated_at` date of Group
    touch(:updated_at)
    unless save
      logger.error(errors.full_messages)
    end

    url = "https://api.rozklad.org.ua/v2/groups/#{server_id}/lessons"
    # Init URI
    uri = URI(url)

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
    data = json["data"]

    # Delete old records
    Record.joins(:groups).where('groups.id': id).where("records.updated_at < ?", DateTime.current - 2.day).destroy_all

    # Save records
    for object in data do

      # Get data from JSON
      time = object['time_start']
      pairName = object['lesson_number']
      nameString = object['lesson_full_name']
      kind = object['lesson_type']

      begin
        # Convert to int before find request

        # Conditions for find existing pair
        conditions = {}
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:kind] = kind
        conditions[:time] = time

        # Try to find existing record first
        record = Record.find_by(conditions)

        if record.nil?
          # Save new record
          record = Record.new
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.kind = kind
          
          # Push only unique groups
          unless record.groups.include?(self)
             record.groups << self
          end

          unless record.save
            # Go to the next iteration if record can't be saved
            logger.error(record.errors.full_messages)
            next
          end
          
        else
          # Update record
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.kind = kind
          
          # Push only unique groups
          unless record.groups.include?(self)
             record.groups << self
          end

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

  def importRecordsForSumDU
    # Update `updated_at` date of Group
    touch(:updated_at)
    unless save
      logger.error(errors.full_messages)
    end
    
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
        conditions[:reason] = reason
        conditions[:kind] = kind
        conditions[:time] = time

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
          record.teacher = teacher
          
          # Push only unique groups
          unless record.groups.include?(self)
             record.groups << self
          end

          unless record.save
            # Go to the next iteration if record can't be saved
            logger.error(record.errors.full_messages)
            next
          end
          
        else
          # Update record
          record.start_date = startDate
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind

          # Associations
          record.auditorium = auditorium
          record.teacher = teacher
          
          # Push only unique groups
          unless record.groups.include?(self)
             record.groups << self
          end

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
