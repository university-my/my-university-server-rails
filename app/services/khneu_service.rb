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

    # Teachers
    request_teachers(departments_ids)
  end

  # 1. Request departments for import teachers
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
      departments_ids.push(department_id)
    end

    # IDs of all departments
    return departments_ids
  end

  # 2. Iterate through all deparments_ids
  def self.request_teachers(departments_ids)
    departments_ids.each do |department_id| 
      request_teachers_in_department(department_id)
    end
  end

  # 3. Request teacher by department_id
  def self.request_teachers_in_department(department_id)
    # Peform network request and parse XML
    url = "http://services.ksue.edu.ua:8081/schedule/xmlmetadata?q=employees&departmentid=#{department_id}&auth=test"

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

    @doc = doc.xpath('//element').each do |group|
      teacher_id = group.attributes['id'].value
      teacher_name = group.at('./displayName').children.to_s

      # Save to DB
      save_teacher(teacher_id, teacher_name)
    end
  end

  # 4. Save teacher to the DB
  def self.save_teacher(server_id, teacher_name)

    begin

      # This teachers for KHNEU
      university = University.find_by(url: "khnue")
      
      # Conditions for find existing teacher
      conditions = {}
      conditions[:university_id] = university.id
      conditions[:server_id] = server_id
      conditions[:name] = teacher_name
      
      # Try to find existing teacher first
      teacher = Teacher.find_by(conditions)
      
      if teacher.nil?
        # Save new teacher
        teacher = Teacher.new
        teacher.server_id = server_id
        teacher.name = teacher_name
        teacher.university = university
        
        unless teacher.save
          # Go to the next iteration if can't be saved
          p teacher.errors.full_messages
          Rails.logger.error(teacher.errors.full_messages)
        end
      end
      
    rescue Exception => e 
      p e
      Rails.logger.error(e)
    end
  end

  #
  # Import groups from KHNEU API
  #

  # bin/rails runner 'KhneuService.import_groups'
  def self.import_groups
    # Faculties
    faculties_ids = request_faculties()

    # Specialities
    request_specialities(faculties_ids)
  end

  # 1. Request faculties for import groups
  def self.request_faculties
    # Peform network request and parse XML
    url = "http://services.ksue.edu.ua:8081/schedule/xmlmetadata?q=faculties&auth=test"
    
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

    faculties_ids = []

    @doc = doc.xpath('//element').each do |faculty|
      faculty_id = faculty.attributes['id'].value
      faculties_ids.push(faculty_id)
    end

    # IDs of all faculties
    return faculties_ids
  end

  # 2. Request specialities by faculties_ids. 
  # And request group by faculty_id and specialty_id.
  def self.request_specialities(faculties_ids)

    faculties_ids.each do |faculty_id| 
      specialities_ids = request_specialty(faculty_id)

      specialities_ids.each do |specialty_id|
        for course in 1..6 do
          request_groups(faculty_id, specialty_id, course)
        end
      end
    end
  end

  # 3. Request specialty by faculty_id
  def self.request_specialty(faculty_id)
    # Peform network request and parse XML
    url = "http://services.ksue.edu.ua:8081/schedule/xmlmetadata?q=specialities&facultyid=#{faculty_id}&auth=test"

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

    specialities_ids = []

    @doc = doc.xpath('//element').each do |specialty|
      specialty_id = specialty.attributes['id'].value
      specialities_ids.push(specialty_id)
    end

    # IDs of specialities
    return specialities_ids
  end

  # 4. Request groups by faculty_id, specialty_id and course
  def self.request_groups(faculty_id, specialty_id, course)
    # Peform network request and parse XML
    url = "http://services.ksue.edu.ua:8081/schedule/xmlmetadata?q=groups&facultyid=#{faculty_id}&specialityid=#{specialty_id}&course=#{course}&auth=test"

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

    @doc = doc.xpath('//element').each do |group|
      groupID = group.attributes['id'].value
      groupName = group.at('./displayName').children.to_s

      # Save to DB
      save_group(groupID, groupName)
    end
  end
  
  # 4. Save group to the DB
  def self.save_group(server_id, group_name)

    begin

      # This groups for KHNEU
      university = University.find_by(url: "khnue")
      
      # Conditions for find existing group
      conditions = {}
      conditions[:university_id] = university.id
      conditions[:server_id] = server_id
      conditions[:name] = group_name
      
      # Try to find existing group first
      group = Group.find_by(conditions)
      
      if group.nil?
        # Save new group
        group = Group.new
        group.server_id = server_id
        group.name = group_name
        group.university = university
        
        unless group.save
          # Go to the next iteration if can't be saved
          p group.errors.full_messages
          Rails.logger.error(group.errors.full_messages)
        end
      end
      
    rescue Exception => e 
      p e
      Rails.logger.error(e)
    end
  end

end