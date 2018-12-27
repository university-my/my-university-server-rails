require 'net/http'
require 'json'

class Group < ApplicationRecord

  # Field validations
  validates :name, presence: true, allow_blank: false
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_many :records

  # Import for SumDU
  # bin/rails runner 'Group.importSumDU'
  def self.importSumDU

    logger.info "Start import SumDU groups"

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

    for object in json do
      serverID = Integer(object[0])
      groupName = object[1]

      # Save new group
      group = Group.new
      group.server_id = serverID
      group.name = groupName
      group.save
    end
  end

  def importRecords
    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_grp=#{server_id}&id_fio=0&id_aud=0"

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
      type = object['NAME_STUD']

      # Save new record
      record = Record.new
      record.start_date = dateString.to_datetime
      record.time = time
      record.pair_name = pairName
      record.name = nameString
      record.reason = reason
      record.type = type
      record.group_id = id
      record.save
    end
  end

end
