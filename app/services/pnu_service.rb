require 'net/http'
require 'json'
require "uri"

class PnuService

  def self.load_objects(object_type)
    # URI
    uri = URI.parse("https://ultimate-schedule.fun/v1/#{object_type}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Headers
    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "My University Ruby Script"
    request["Accept"] = "application/json"
    request["X-Schedule-Url"] = "http://asu.pnu.edu.ua/cgi-bin/timetable.cgi"

    # Make reequest
    response = http.request(request)

    # Parse JSON
    json = JSON.parse(response.body)
    groups = json['data']

    return groups
  end

  #
  # Import groups
  #
  # bin/rails runner 'PnuService.import_groups'
  def self.import_groups
    groups = self.load_objects('groups')

    university = University.pnu

    groups.each do |object|


      server_id = 101
      group_name = object

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
          Rails.logger.error(group.errors.full_messages)
          next
        end
      end
    rescue StandardError => e
      Rails.logger.error(e)
      next

    end
  end

  #
  # Import teachers
  #
  # bin/rails runner 'PnuService.import_teachers'
  def self.import_teachers
    teachers = self.load_objects('teachers')

    university = University.pnu

    teachers.each do |object|


      server_id = 101
      teacher_name = object

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
          Rails.logger.error(teacher.errors.full_messages)
          next
        end
      end
    rescue StandardError => e
      Rails.logger.error(e)
      next

    end
  end

  #
  # Import records for group
  #
  def self.import_records_for_group(group, date)
    start_date = date.strftime('%d.%m.%Y')
    end_date = (date + 7.day).strftime('%d.%m.%Y')

    # URI
    uri = URI.parse("https://ultimate-schedule.fun/v1/schedule/groups")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Params
    params = {
      'value' => group.name,
      'date_from' => start_date,
      'date_to' => end_date
    }
    uri.query = URI.encode_www_form(params)

    # Headers
    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "My University Ruby Script"
    request["Accept"] = "application/json"
    request["X-Schedule-Url"] = "http://asu.pnu.edu.ua/cgi-bin/timetable.cgi"

    # Make reequest
    response = http.request(request)

    # Parse JSON
    json = JSON.parse(response.body)
    data = json['data']

    university = University.pnu

    data.each do |object|
      
      date_string = object['date']
      lessons = object['lessons']

      lessons.each do |lesson|

        pair_start_date = (date_string + ' ' + lesson['from']).to_datetime

        self.save_or_update_record(
          pair_start_date,
          lesson['number'],
          lesson['description'].strip,
          lesson['from'] + '-' + lesson['to'],
          nil,
          [group],
          university
          )
      end

    end


    # Update `updated_at` date of Group
    group.touch(:updated_at)
    Rails.logger.error(errors.full_messages) unless group.save
  end

  #
  # Record
  #
  def self.save_or_update_record(pair_start_date, pair_name, reason, time, teacher, groups, university)
    # Conditions for find existing pair
    conditions = {}
    conditions[:university_id] = university.id
    conditions[:pair_start_date] = pair_start_date
    conditions[:pair_name] = pair_name
    conditions[:reason] = reason
    conditions[:time] = time

    # Try to find existing record first
    record = Record.find_by(conditions)

    if record.nil?
      # New record
      record = Record.new
    end

    # Update record
    record.pair_start_date = pair_start_date
    record.time = time
    record.pair_name = pair_name
    record.name = ''
    record.reason = reason
    record.kind = ''
    record.university = university

    # Associations
    record.teacher = teacher

    # Push only unique groups
    groups.each do |group|
      record.groups << group unless record.groups.include?(group)
    end

    return if record.save
  end

end