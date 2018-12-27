require 'net/http'
require 'json'

class Group < ApplicationRecord

  # Field validations
  validates :name, presence: true, allow_blank: false
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

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
end
