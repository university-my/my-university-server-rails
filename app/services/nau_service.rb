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

    if json.nil?
      return
    end

    schedule = json['schedule']

    if schedule.nil?
      return
    end

    schedule.each { |object|
      week_day = object.first
      data_items = week_day.split('.')

      week_number = data_items[0].to_i
      day_abbreviation = data_items[1]
      pair_number = data_items[2]
      pair_start_date = calculate_pair_date(date, week_number, day_abbreviation)

      data = object.last
      discipline = data["discipline"]

      save_record_for_group(group, pair_start_date, discipline, pair_number)
    }

  end

  def self.save_record_for_group(group, pair_start_date, name, pair_number)
    university = University.nau

    # Conditions for find existing pair
    conditions = {}
    conditions[:university_id] = university.id
    conditions[:pair_start_date] = pair_start_date
    conditions[:name] = name
    conditions[:pair_name] = pair_number

    # Try to find existing record first
    record = Record.find_by(conditions)

    if record.nil?
      # Save new record
      record = Record.new
      record.pair_start_date = pair_start_date
      record.pair_name = pair_number
      record.name = name
      record.university = university

      # Push only unique groups
      unless record.groups.include?(group)
        record.groups << group
      end

      unless record.save
        # Go to the next iteration if record can't be saved
        Rails.logger.error(record.errors.full_messages)
      end
    else
      # Update record
      record.pair_start_date = pair_start_date
      record.pair_name = pair_number
      record.name = name
      record.university = university

      # Push only unique groups
      unless record.groups.include?(group)
        record.groups << group
      end

      unless record.save
        # Go to the next iteration if record can't be saved
        Rails.logger.error(record.errors.full_messages)
      end
    end
  end

  def self.calculate_pair_date(selected_pair_date, lesson_week, day_abbreviation)

    day_number = 7
    if day_abbreviation == "Пнд"
      day_number = 1
    elsif day_abbreviation == "Втр"
      day_number = 2
    elsif day_abbreviation == "Срд"
      day_number = 3
    elsif day_abbreviation == "Чтв"
      day_number = 4
    elsif day_abbreviation == "Птн"
      day_number = 5
    elsif day_abbreviation == "Сбт"
      day_number = 6
    end

    # Get current week
    current_week = week_for_selected_date(selected_pair_date)

    # Calculate pair date
    year = selected_pair_date.year
    day = day_number
    if lesson_week == current_week
      week = selected_pair_date.cweek
    elsif lesson_week > current_week
      week = selected_pair_date.cweek + 1
    elsif lesson_week < current_week
      week = selected_pair_date.cweek - 1
    end
    # `beginning_of_day` for prevent duplication
    pair_start_date = Date.commercial(year, week, day).beginning_of_day
    return pair_start_date
  end

  # Week for current date
  def self.week_for_selected_date(selected_pair_date)
    remainder_of_division = selected_pair_date.cweek % 2
    if remainder_of_division == 0
      return 1
    else
      return 2
    end
  end

end
