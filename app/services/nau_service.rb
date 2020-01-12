require 'net/http'
require 'json'

module NauService

  def self.baseURL
    "http://rozklad.nau.edu.ua/api/v1"
  end

  #
  # Departments
  #

  # bin/rails runner 'NauService.import_departments'
  def self.import_departments
    url = "#{baseURL}/departments"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return
    end

    objects = json['departments']

    for object in objects do
      faculty_id = object['CODE'].to_i
      faculty_name = object['NAME']

      # Save department
      save_faculty(faculty_id, faculty_name)

      # Import groups for department
      import_groups(faculty_id)
    end
  end

  def self.save_faculty(faculty_id, faculty_name)
    university = University.nau
    faculty = Faculty.where(university: university, server_id: faculty_id, name: faculty_name).first

    if faculty.nil?
      # Save new faculty
      faculty = Faculty.new
      faculty.server_id = faculty_id
      faculty.name = faculty_name
      faculty.university = university

      unless faculty.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(faculty.errors.full_messages)
      end
    end
  end

  #
  # Group
  #
  def self.import_groups(faculty_id)
    url = "#{baseURL}/groups/#{faculty_id}"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return
    end

    objects = json['groups']

    if objects.nil?
      return
    end

    for object in objects do
      # Save groups

      # ID is not unique
      group_id = object['GRP'].to_i
      name = object['NAME']
      course = object['COURSE'].to_i
      stream = object['STRM'].to_i
      save_group(group_id, name, course, stream, faculty_id)
    end
  end

  def self.save_group(group_id, name, course, stream, faculty_id)
    begin
      university = University.nau
      faculty = Faculty.where(university: university)
      .where(server_id: faculty_id).first

      # Conditions for find existing group
      conditions = {}
      conditions[:university_id] = university.id
      conditions[:server_id] = group_id
      conditions[:name] = name
      conditions[:course] = course
      conditions[:stream] = stream
      conditions[:faculty] = faculty

      # Try to find existing group first
      group = Group.find_by(conditions)

      if group.nil?
        # Save new group
        group = Group.new
        group.server_id = group_id
        group.name = name
        group.university = university
        group.course = course
        group.stream = stream
        group.faculty = faculty

        unless group.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(group.errors.full_messages)
        end
      end

    rescue Exception => e
      Rails.logger.error(e)
    end
  end

  def self.import_records_for_group(group, date)
    # Faculty
    faculty_id = group.faculty.server_id
    if faculty_id.nil?
      return
    end

    url = "#{baseURL}/schedule/#{faculty_id}/#{group.course}/#{group.stream}/#{group.server_id}"
    json = ApplicationRecord.perform_request(url)

    p '---'
    p url

    if json.nil?
      return
    end

  end

end
