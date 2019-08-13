require 'net/http'
require 'nokogiri'

# Service for import data from KHNEU
module KhneuService

  #
  # Import teachers from KHNEU API
  #

  # bin/rails runner 'KhneuService.import_teachers'
  def self.import_teachers
    # Departments
    departments_ids = request_departments()

    # Specialities
    # request_specialities(departments_ids)
  end


  # bin/rails runner 'KhneuService.request_departments'
  def self.request_departments
    # Peform network request and parse XML
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

    departments_ids = []

    @doc = doc.xpath('//element').each do |department|
      department_id = department.attributes['id'].value

      p department

      departments_ids.push(department_id)
    end

    p 'departments_ids = '
    p departments_ids

    # IDs of all departments
    return departments_ids

  end

  def self.request_specialities(departments_ids)
    p '---------'
    departments_ids.each do |id| 
      request_specialty(id)
    end
  end

  def self.request_specialty(department_id)
    # Peform network request and parse XML
    url = "http://services.ksue.edu.ua:8081/schedule/xmlmetadata?q=specialities&facultyid=#{department_id}&auth=test"

    p url

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

    @doc = doc.xpath('//element').each do |specialty|
      p specialty
    end

  end

end