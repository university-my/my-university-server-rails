require 'net/http'
require 'nokogiri'

# Service for import data from KHNEU
module KhneuService

  #
  # Import teachers from KHNEU API
  #

  # bin/rails runner 'KhneuService.import_teachers'
  def self.import_teachers
    # Peform network request and parse JSON
    # url = "http://schedule.sumdu.edu.ua/index/json?method=getTeachers"
    # json = ApplicationRecord.perform_request(url)
  end


  # bin/rails runner 'KhneuService.request_departments'
  def self.request_departments
    # Peform network request and parse JSON
    url = "http://services.ksue.edu.ua:8081/schedule/xmlmetadata?q=departments&auth=test"
    
    # Init URI
    uri = URI(url)

    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    doc = Nokogiri::XML(response.body)

    @doc = doc.xpath('//element').each do |department|
      department_id = department.attributes['id'].value
      department_name = department.at('displayName').text
    end

  end

end