require 'net/http'
require 'nokogiri'

# Service for import data from KHNUE
module KhnueService

  def self.baseURL
    "http://services.ksue.edu.ua:8081/schedule/xmlmetadata"
  end

  def self.authKey
    "auth=test"
  end

  def self.perform_request(url)
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
    return doc
  end

  #
  # Import records for auditorium from KHNUE API
  #

  def self.import_records_for_auditorium(auditorium, date)
    week_number = date.cweek

    url = 'http://services.ksue.edu.ua:8081/schedule/xml'
    query = "?room=#{auditorium.server_id}&week=#{week_number}&#{authKey}"

    doc = perform_request(url + query)

    p '======'
    p '======'
    p url + query
    p '======'

    schedule = doc.at('//schedule//week')

    schedule.children.each do |day|
      p '---'
      p day
    end
  end

  #
  # Import records for groups from KHNUE API
  #

  def self.import_records_for_group(group, date)
    # Because in API first week begins in 1th of September
    weeks_shift = 34
    current_week = date.cweek
    week_number = 1

    if current_week == 35
      week_number = 1

    elsif current_week > weeks_shift
      week_number = current_week - weeks_shift

    elsif weeks_shift > current_week
      week_number = current_week + weeks_shift
    end

    url = 'http://services.ksue.edu.ua:8081/schedule/xml'
    query = "?group=#{group.server_id}&week=#{week_number}&#{authKey}"

    doc = perform_request(url + query)

    p '======'
    p url + query
    p '======'

    @doc = doc.xpath('//schedule-element').each do |element|
      # Start date
      start = element.attributes['start'].value
      date = element.attributes['date'].value
      date_string = "#{date} #{start}"

      # Name
      name_string = element.attributes['pair'].value

      # Pair name
      pair_name = element.at('//subject').children.to_s

      # Kind
      kind = element.at('//type').children.to_s

      # Time
      time = start

      # Auditorium
      auditorium_id = element.at('//room').attributes['id'].value

      # Teacher
      teacher_id = element.at('//teacher').attributes['id'].value

      # Groups
      groups_ids = []
      element.xpath("//group").each do |node|
        group_id = node.attributes['id'].value
        groups_ids.push(group_id)
      end

      # Save to DB
      save_or_update_record(date_string, name_string, pair_name, kind, time, auditorium_id, teacher_id, groups_ids)
    end
  end

  def self.save_or_update_record(date_string, name_string, pair_name, kind, time, auditorium_id, teacher_id, groups_ids)

    university = University.find_by(url: "khnue")

    begin
      # Auditorium
      auditorium = Auditorium.find_by(university_id: university.id, server_id: auditorium_id.to_i)
      
      # Groups
      groups = Group.where(university_id: university.id, server_id: groups_ids)
      
      # Teacher
      teacher = Teacher.where(university_id: university.id, server_id: teacher_id.to_i).first
      
      # Pair start date
      start_date = date_string.to_datetime

      # Conditions for find existing pair
      conditions = {}
      conditions[:university_id] = university.id
      conditions[:start_date] = start_date
      conditions[:name] = name_string
      conditions[:pair_name] = pair_name
      conditions[:kind] = kind
      conditions[:time] = time

      # Try to find existing record first
      record = Record.find_by(conditions)
      
      if record.nil?
        # Save new record
        record = Record.new
        record.start_date = start_date
        record.pair_start_date = start_date
        record.time = time
        record.pair_name = pair_name
        record.name = name_string
        record.reason = nil
        record.kind = kind
        record.university = university

        # Associations
        record.auditorium = auditorium
        record.teacher = teacher

        # Push only unique groups
        for group in groups do
          unless record.groups.include?(group)
            record.groups << group
          end
        end
        
        # Try to save record
        unless record.save
          # Go to the next iteration if record can't be saved
          p record.errors.full_messages
          Rails.logger.error(record.errors.full_messages)
        end
        
      else
        # Record not nil
        # Update record
        record.start_date = start_date
        record.pair_start_date = start_date
        record.time = time
        record.pair_name = pair_name
        record.name = name_string
        record.reason = nil
        record.kind = kind
        record.university = university

        # Associations
        record.auditorium = auditorium
        record.teacher = teacher

        # Push only unique groups
        for group in groups do
          unless record.groups.include?(group)
            record.groups << group
          end
        end
      
        unless record.save
          # Go to the next iteration if record can't be saved
          p record.errors.full_messages
          Rails.logger.error(record.errors.full_messages)
        end
        
      end
      

    rescue Exception => e
      p e
      Rails.logger.error(e)
    end
  end

  #
  # Import auditoriums from KHNUE API
  #

  # bin/rails runner 'KhnueService.import_auditoriums'
  def self.import_auditoriums
    buildings_ids = request_building()

    request_auditoriums(buildings_ids)
  end

  # 1. Request building for import auditoriums
  def self.request_building
    url = "#{baseURL}?q=buildings&#{authKey}"
    doc = perform_request(url)

    buildings_ids = []

    @doc = doc.xpath('//element').each do |building|
      building_id = building.attributes['id'].value
      buildings_ids.push(building_id)
    end

    # IDs of all building
    return buildings_ids
  end

  # 2. Iterate through all buildings_ids
  def self.request_auditoriums(buildings_ids)
    buildings_ids.each do |building_id|
      request_auditoriums_in_building(building_id)
    end
  end

  # 3. Request auditoriums in building
  def self.request_auditoriums_in_building(building_id)
    url = "#{baseURL}?q=rooms&buildingid=#{building_id}&#{authKey}"

    doc = perform_request(url)

    @doc = doc.xpath('//element').each do |auditorium|
      auditorium_id = auditorium.attributes['id'].value
      auditorium_name = auditorium.at('./displayName').children.to_s

      # Save to DB
      save_auditorium(auditorium_id, auditorium_name)
    end
  end

  # 4. Save auditorium to the DB
  def self.save_auditorium(server_id, auditorium_name)

    begin
      university = University.find_by(url: "khnue")

      # Conditions for find existing auditorium
      conditions = {}
      conditions[:university_id] = university.id
      conditions[:server_id] = server_id
      conditions[:name] = auditorium_name

      # Try to find existing auditorium first
      auditorium = Auditorium.find_by(conditions)

      if auditorium.nil?
        # Save new auditorium
        auditorium = Auditorium.new
        auditorium.server_id = server_id
        auditorium.name = auditorium_name
        auditorium.university = university

        unless auditorium.save
          # Go to the next iteration if can't be saved
          p auditorium.errors.full_messages
          Rails.logger.error(auditorium.errors.full_messages)
        end
      end

    rescue Exception => e
      p e
      Rails.logger.error(e)
    end
  end

  #
  # Import teachers from KHNUE API
  #

  # bin/rails runner 'KhnueService.import_teachers'
  def self.import_teachers
    # Departments
    departments_ids = request_departments()

    # Teachers
    request_teachers(departments_ids)
  end

  # 1. Request departments for import teachers
  def self.request_departments
    url = "#{baseURL}?q=departments&#{authKey}"
    doc = perform_request(url)

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
    url = "#{baseURL}?q=employees&departmentid=#{department_id}&#{authKey}"
    doc = perform_request(url)

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
  # Import groups from KHNUE API
  #

  # bin/rails runner 'KhnueService.import_groups'
  def self.import_groups
    # Faculties
    faculties_ids = request_faculties()

    # Specialities
    request_specialities(faculties_ids)
  end

  # 1. Request faculties for import groups
  def self.request_faculties
    url = "#{baseURL}?q=faculties&#{authKey}"
    doc = perform_request(url)

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
    url = "#{baseURL}?q=specialities&facultyid=#{faculty_id}&#{authKey}"
    doc = perform_request(url)

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
    url = "#{baseURL}?q=groups&facultyid=#{faculty_id}&specialityid=#{specialty_id}&course=#{course}&#{authKey}"
    doc = perform_request(url)

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