require 'net/http'
require 'json'

class Auditorium < ApplicationRecord
  self.table_name = "auditoriums"

  # Field validations
  validates :name, presence: true, allow_blank: false
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
end
