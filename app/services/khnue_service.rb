require 'net/http'
require 'nokogiri'

# Service for import data from KHNUE
module KhnueService

  def self.baseURL
    "http://services.ksue.edu.ua:8081/schedule/xmlmetadata"
  end

  def self.authKey
    "auth=vy_1be6600087"
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

  def self.calculate_week(date)
    # Because of strange week numbers in API
    weeks_shift = 17
    current_week = date.cweek
    week_number = 1

    if current_week == 17
      week_number = 1

    elsif current_week > weeks_shift
      week_number = current_week - weeks_shift

    elsif weeks_shift > current_week
      week_number = current_week + weeks_shift
    end
    return week_number
  end

  def self.parse_and_save_records(doc)
    @doc = doc.xpath('//schedule-element').each do |element|
      # Start date
      start_time_string = element.attributes['start'].value
      date_string = element.attributes['date'].value

      # Pair name
      pair_name = element.attributes['pair'].value

      # Name
      subject = element.at('./subject')
      name_string = nil
      if subject
        name_string = subject.children.to_s
      end

      # Kind
      type = element.at('./type')
      kind = nil
      if type
        kind = type.children.to_s
      end

      # Auditorium
      room = element.at('./room')
      auditorium_id = nil
      if room
        auditorium_id = room.attributes['id'].value
      end

      # Teacher
      teacher = element.at('./teacher')
      teacher_name = nil
      if teacher and teacher.attributes['full-name']
        teacher_name = teacher.attributes['full-name'].value
      end

      # Groups
      groups_ids = []
      groups = element.xpath("./groups")
      groups.xpath("./group").each do |node|
        group_id = node.attributes['id'].value
        groups_ids.push(group_id)
      end

      # Save to DB
      save_or_update_record(date_string, start_time_string, name_string, pair_name, kind, auditorium_id, teacher_name, groups_ids)
    end
  end

  #
  # Import records for auditorium from KHNUE API
  #

  def self.import_records_for_auditorium(auditorium, date)
    week_number = calculate_week(date)

    url = 'http://services.ksue.edu.ua:8081/schedule/xml'
    query = "?room=#{auditorium.server_id}&week=#{week_number}&#{authKey}"

    doc = perform_request(url + query)
    parse_and_save_records(doc)

    # Update `updated_at` date of Auditorium
    auditorium.touch(:updated_at)
    unless auditorium.save
      Rails.logger.error(errors.full_messages)
    end
  end

  #
  # Import records for group from KHNUE API
  #

  def self.import_records_for_group(group, date)
    week_number = calculate_week(date)

    url = 'http://services.ksue.edu.ua:8081/schedule/xml'
    query = "?group=#{group.server_id}&week=#{week_number}&#{authKey}"

    doc = perform_request(url + query)
    parse_and_save_records(doc)

    # Update `updated_at` date of Group
    group.touch(:updated_at)
    unless group.save
      Rails.logger.error(errors.full_messages)
    end
  end

  #
  # Import records for teacher from KHNUE API
  #

  def self.import_records_for_teacher(teacher, date)
    week_number = calculate_week(date)

    url = 'http://services.ksue.edu.ua:8081/schedule/xml'
    query = "?employee=#{teacher.server_id}&week=#{week_number}&#{authKey}"

    doc = perform_request(url + query)
    parse_and_save_records(doc)

    # Update `updated_at` date of Teacher
    teacher.touch(:updated_at)
    unless teacher.save
      Rails.logger.error(errors.full_messages)
    end
  end


  def self.save_or_update_record(date_string, start_time_string, name_string, pair_name, kind, auditorium_id, teacher_name, groups_ids)
    university = University.khnue

    begin
      # Auditorium
      auditorium = Auditorium.find_by(university: university, server_id: auditorium_id.to_i)

      # Groups
      groups = Group.where(university: university, server_id: groups_ids)

      # Teacher
      teacher = Teacher.where(university: university, name: teacher_name).first

      # Pair start date
      start_date = date_string.to_datetime
      pair_start_date = "#{date_string} #{start_time_string}".to_datetime

      # Conditions for find existing pair
      conditions = {}
      conditions[:university_id] = university.id
      conditions[:start_date] = start_date
      conditions[:name] = name_string
      conditions[:pair_name] = pair_name
      conditions[:kind] = kind
      conditions[:time] = start_time_string

      # Try to find existing record first
      record = Record.find_by(conditions)

      if record.nil?
        # Save new record
        record = Record.new
        record.start_date = start_date
        record.pair_start_date = pair_start_date
        record.time = start_time_string
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

        # Save or update Discipline
        discipline = save_discipline(name_string, auditorium, groups, teacher)
        record.discipline = discipline

        # Try to save record
        unless record.save
          # Go to the next iteration if record can't be saved
          Rails.logger.error(record.errors.full_messages)
        end

      else
        # Record not nil
        # Update record
        record.start_date = start_date
        record.pair_start_date = pair_start_date
        record.time = start_time_string
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

        # Save or update Discipline
        discipline = save_discipline(name_string, auditorium, groups, teacher)
        record.discipline = discipline

        unless record.save
          # Go to the next iteration if record can't be saved
          Rails.logger.error(record.errors.full_messages)
        end

      end


    rescue Exception => e
      Rails.logger.error(e)
    end
  end

  #
  # Import auditoriums from KHNUE API
  #

  # bin/rails runner 'KhnueService.import_auditoriums'
  def self.import_auditoriums
    buildings_ids = request_buildings()

    request_auditoriums(buildings_ids)
  end

  # 1. Request building for import auditoriums
  def self.request_buildings
    url = "#{baseURL}?q=buildings&#{authKey}"
    doc = perform_request(url)

    buildings_ids = []

    @doc = doc.xpath('//element').each do |building|
      building_id = building.attributes['id'].value
      building_name = building.at('./displayName').children.to_s

      save_building(building_id, building_name)
      buildings_ids.push(building_id)
    end

    # IDs of all building
    return buildings_ids
  end

  def self.save_building(server_id, name)
    building = Building.where(server_id: server_id, name: name).first
    university = University.khnue

    if building.nil?
      # Save new building
      building = Building.new
      building.server_id = server_id
      building.name = name
      building.university = university

      unless building.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(building.errors.full_messages)
      end
    end
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
      save_auditorium(auditorium_id, auditorium_name, building_id)
    end
  end

  # 4. Save auditorium to the DB
  def self.save_auditorium(server_id, auditorium_name, building_id)

    begin
      university = University.khnue
      building = Building.where(university: university)
      .where(server_id: building_id).first

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
        auditorium.building = building

        unless auditorium.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(auditorium.errors.full_messages)
        end
      else
        # Update
        auditorium.building = building
        unless auditorium.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(auditorium.errors.full_messages)
        end
      end

    rescue Exception => e
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
      department_name = department.at('./displayName').children.to_s
      save_department(department_id, department_name)

      departments_ids.push(department_id)
    end

    # IDs of all departments
    return departments_ids
  end

  def self.save_department(id, name)
    department = Department.where(server_id: id, name: name).first
    university = University.khnue

    if department.nil?
      # Save new department
      department = Department.new
      department.server_id = id
      department.name = name
      department.university = university

      unless department.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(department.errors.full_messages)
      end
    end
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
      save_teacher(teacher_id, teacher_name, department_id)
    end
  end

  # 4. Save teacher to the DB
  def self.save_teacher(server_id, teacher_name, department_id)

    begin
      university = University.khnue
      department = Department.where(university: university)
      .where(server_id: department_id).first

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
        teacher.department = department
        teacher.university = university

        unless teacher.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(teacher.errors.full_messages)
        end
      else
        # Update
        teacher.department = department
        unless teacher.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(teacher.errors.full_messages)
        end
      end

    rescue Exception => e
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
      faculty_name = faculty.at('./displayName').children.to_s
      save_faculty(faculty_id, faculty_name)

      faculties_ids.push(faculty_id)
    end

    # IDs of all faculties
    return faculties_ids
  end

  def self.save_faculty(id, name)
    faculty = Faculty.where(server_id: id, name: name).first
    university = University.khnue

    if faculty.nil?
      # Save new faculty
      faculty = Faculty.new
      faculty.server_id = id
      faculty.name = name
      faculty.university = university

      unless faculty.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(faculty.errors.full_messages)
      end
    end
  end

  # 2. Request specialities by faculties_ids.
  # And request group by faculty_id and speciality_id.
  def self.request_specialities(faculties_ids)

    faculties_ids.each do |faculty_id|
      specialities_ids = request_specialty(faculty_id)

      specialities_ids.each do |speciality_id|
        for course in 1..6 do
          request_groups(faculty_id, speciality_id, course)
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
      speciality_id = specialty.attributes['id'].value
      speciality_name = specialty.at('./displayName').children.to_s
      save_speciality(speciality_id, speciality_name)

      specialities_ids.push(speciality_id)
    end

    # IDs of specialities
    return specialities_ids
  end

  def self.save_speciality(id, name)
    speciality = Speciality.where(server_id: id, name: name).first
    university = University.khnue

    if speciality.nil?
      # Save new speciality
      speciality = Speciality.new
      speciality.server_id = id
      speciality.name = name
      speciality.university = university

      unless speciality.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(speciality.errors.full_messages)
      end
    end
  end

  # 4. Request groups by faculty_id, speciality_id and course
  def self.request_groups(faculty_id, speciality_id, course)
    url = "#{baseURL}?q=groups&facultyid=#{faculty_id}&specialityid=#{speciality_id}&course=#{course}&#{authKey}"
    doc = perform_request(url)

    @doc = doc.xpath('//element').each do |group|
      group_id = group.attributes['id'].value
      group_name = group.at('./displayName').children.to_s

      # Save to DB
      save_group(group_id, group_name, faculty_id, speciality_id)
    end
  end

  # 4. Save group to the DB
  def self.save_group(server_id, group_name, faculty_id, speciality_id)

    begin
      university = University.khnue
      faculty = Faculty.where(university: university)
      .where(server_id: faculty_id).first
      speciality = Speciality.where(university: university)
      .where(server_id: speciality_id).first

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
        group.faculty = faculty
        group.speciality = speciality

        unless group.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(group.errors.full_messages)
        end
      else
        # Update
        group.faculty = faculty
        group.speciality = speciality
        unless group.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(group.errors.full_messages)
        end
      end

    rescue Exception => e
      Rails.logger.error(e)
    end
  end

  #
  # Import Discipline
  #
  def self.save_discipline(name, auditorium, groups, teacher)
    university = University.khnue
    discipline = Discipline.save_or_update(name, university, auditorium, groups, teacher)
    return discipline
  end

end
