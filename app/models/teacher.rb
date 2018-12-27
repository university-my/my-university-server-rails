require 'net/http'
require 'json'

class Teacher < ApplicationRecord

  # Field validations
  validates :name, presence: true, allow_blank: false
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_many :records

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

    # Delete before save
    Teacher.destroy_all

    for object in json do
      serverID = Integer(object[0])
      teacherName = object[1]

      # Save new teacher
      teacher = Teacher.new
      teacher.server_id = serverID
      teacher.name = teacherName
      teacher.save
    end
  end
end
