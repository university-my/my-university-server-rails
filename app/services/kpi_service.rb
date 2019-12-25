require 'net/http'
require 'json'

module KpiService

  #
  # Classrooms
  #

  def self.import_classrooms(classrooms, university)
    auditoriums = []
    for classroom in classrooms do
      classroom_id = classroom['room_id']
      classroom_name = classroom['room_name']

      auditorium = Auditorium.find_by(university_id: university.id, server_id: classroom_id)
      if auditorium.nil?
        auditorium = Auditorium.new
        auditorium.server_id = classroom_id
        auditorium.name = classroom_name
        auditorium.university = university
        auditorium.building = nil

        unless auditorium.save
          # Go to the next iteration if auditorium can't be saved
          Rails.logger.error(record.errors.full_messages)
          next
        end
      end

      # Push only unique auditoriums
      unless auditoriums.include?(auditorium)
        auditoriums << auditorium
      end
    end

    return auditoriums
  end

  #
  # Import records for group from KPI API
  #

  def self.import_records_for_group(group, selected_pair_date)
    # Get current week
    current_week = week_for_selected_date(selected_pair_date)

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/groups/#{group.server_id}/lessons"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return
    end

    data = json["data"]

    university = University.kpi

    # Save records
    for object in data do

      # Get data from JSON
      time = object['time_start']
      pair_name = object['lesson_number']
      name_string = object['lesson_full_name']
      kind = object['lesson_type']
      day_number = object['day_number'].to_i
      lesson_week = object['lesson_week'].to_i

      # Teahcer
      teachers = object['teachers']

      # Classrooms
      classrooms = object['rooms']

      begin
        # Convert to int before find request

        # Teacher
        teacher = nil
        if teacher_hash = teachers.first
          teacher_id = teacher_hash['teacher_id'].to_i
          teacher = Teacher.find_by(university_id: university.id, server_id: teacher_id)
        end

        # Classrooms
        auditoriums = import_classrooms(classrooms, university)

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
        start_date = date_for_week(year, week, day).beginning_of_day

        # Get pair date and time
        pair_time = time.to_time
        pair_start_date = (start_date.strftime("%F") + ' ' + pair_time.to_s(:time)).to_datetime

        # Don't update old records because we don't want to override it
        current_date = Date.today.beginning_of_day
        if start_date < current_date
          next
        end

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
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pair_name
          record.name = name_string
          record.kind = kind
          record.university = university

          # Associations
          record.auditorium = auditoriums.first
          record.teacher = teacher

          # Push only unique groups
          unless record.groups.include?(group)
           record.groups << group
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            Rails.logger.error(record.errors.full_messages)
            next
          end
        else
          # Update record
          record.start_date = start_date
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pair_name
          record.name = name_string
          record.kind = kind
          record.university = university

          # Associations
          record.auditorium = auditoriums.first
          record.teacher = teacher

          # Push only unique groups
          unless record.groups.include?(group)
           record.groups << group
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            Rails.logger.error(record.errors.full_messages)
            next
          end
        end

      rescue Exception => e
        Rails.logger.error(e)
        next
      end
    end

    # Update `updated_at` date of Group
    group.touch(:updated_at)
    unless group.save
      Rails.logger.error(errors.full_messages)
    end
  end

  #
  # Import records for teacher from KPI API
  #

  def self.import_records_for_teacher(teacher, selected_pair_date)
    # Get current week
    current_week = week_for_selected_date(selected_pair_date)

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/teachers/#{teacher.server_id}/lessons"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return
    end

    data = json["data"]

    university = University.kpi

    # Save records
    for object in data do

      # Get data from JSON
      time = object['time_start']
      pair_name = object['lesson_number']
      name_string = object['lesson_full_name']
      kind = object['lesson_type']
      day_number = object['day_number'].to_i
      lesson_week = object['lesson_week'].to_i

      # Groups
      groups = object['groups']

      # Classrooms
      classrooms = object['rooms']

      begin
        # Group
        groupIDs = Array.new
        for group in groups do
          if id = group['group_id'].to_i
            groupIDs.push(id)
          end
        end
        groups = Group.where(university: university, server_id: groupIDs)

        # Classrooms
        auditoriums = import_classrooms(classrooms, university)

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
        start_date = date_for_week(year, week, day).beginning_of_day

        # Get pair date and time
        pair_time = time.to_time
        pair_start_date = (start_date.strftime("%F") + ' ' + pair_time.to_s(:time)).to_datetime

        # Don't update old records because we don't want to override it
        current_date = Date.today.beginning_of_day
        if start_date < current_date
          next
        end

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:start_date] = start_date
        conditions[:name] = name_string
        conditions[:pair_name] = pair_name
        conditions[:kind] = kind
        conditions[:time] = time
        conditions[:teacher_id] = teacher.id

        # Try to find existing record first
        record = Record.find_by(conditions)

        if record.nil?
          # Save new record
          record = Record.new
          record.start_date = start_date
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pair_name
          record.name = name_string
          record.kind = kind
          record.university = university

          # Associations
          record.teacher = teacher
          record.auditorium = auditoriums.first

          # Push only unique groups
          for group in groups do
            unless record.groups.include?(group)
             record.groups << group
           end
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            Rails.logger.error(record.errors.full_messages)
            next
          end
        else
          # Update record
          record.start_date = start_date
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pair_name
          record.name = name_string
          record.kind = kind
          record.university = university

          # Associations
          record.teacher = teacher
          record.auditorium = auditoriums.first

          # Push only unique groups
          for group in groups do
            unless record.groups.include?(group)
             record.groups << group
           end
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            Rails.logger.error(record.errors.full_messages)
            next
          end
        end

      rescue Exception => e
        Rails.logger.error(e)
        next
      end
    end

    # Update `updated_at` date of Teacher
    teacher.touch(:updated_at)
    unless teacher.save
      Rails.logger.error(errors.full_messages)
    end
  end


  #
  # Import groups from KPI API
  #

  # bin/rails runner 'KpiService.import_groups'
  def self.import_groups
    groups_total_count = KpiService.get_groups_count

    offset = 0

    while offset < groups_total_count
      # Get json with groups from API
      json = KpiService.get_groups(offset)

      # Save to database
      KpiService.save_groups_from(json)

      offset += 100
    end
  end


   # Make request to API for get total count of all groups
   def self.get_groups_count

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/groups"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return 0
    end

    total_count = json["meta"]["total_count"]
    teachers_total_count = Integer(total_count)

    return teachers_total_count
  end


  # Make request with offset parameter and parse JSON
  def self.get_groups(offset)

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/groups/?filter={%27limit%27:100,%27offset%27:#{offset}}"
    json = ApplicationRecord.perform_request(url)
    return json
  end


  # Serialize groups from JSON and save to database
  def self.save_groups_from(json)

    data = json["data"]

    # This groups for SumDU
    university = University.kpi

    for object in data do

      begin
        # Convert before save
        server_id = Integer(object["group_id"])
        group_name = String(object["group_full_name"])

        # Save new group
        group = Group.new
        group.server_id = server_id
        group.name = group_name

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

      rescue Exception => e
        Rails.logger.error(e)
        next
      end
    end
  end

  #
  # Get current week from KPI API
  #

  # Request current week from KPI API
  def self.get_current_week

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/weeks"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return 1
    end

    week = json['data']

    return week
  end

  # Week for current date
  # What we have: Selected date
  # What we need: Week number for selected date
  def self.week_for_selected_date(selected_pair_date)
    remainder_of_division = selected_pair_date.cweek % 2
    if remainder_of_division == 0
      return 1
    else
      return 2
    end
  end

  # Get date from week number and day number
  def self.date_for_week(year, week, day)
    Date.commercial(year, week, day)
  end

  #
  # Import teachers from KPI API
  #

  # Import from KPI
  # bin/rails runner 'KpiService.import_teachers'
  def self.import_teachers
    teachers_total_count = KpiService.get_teachers_count

    offset = 0

    while offset < teachers_total_count
      # Get json with teachers from API
      json = KpiService.get_teachers(offset)

      # Save to database
      KpiService.save_teachers_from(json)

      offset += 100
    end
  end


  # Make request to API for get total count of all teachers
  def self.get_teachers_count

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/teachers"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return
    end

    total_count = json["meta"]["total_count"]
    teachers_total_count = Integer(total_count)

    return teachers_total_count
  end


  # Make request with offset parameter and parse JSON
  def self.get_teachers(offset)
    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/teachers/?filter={%27limit%27:100,%27offset%27:#{offset}}"
    json = ApplicationRecord.perform_request(url)

    return json
  end


  # Serialize teachers from JSON and save to database
  def self.save_teachers_from(json)

    data = json["data"]

    # This groups for SumDU
    university = University.kpi

    for object in data do

      begin
        # Convert before save
        server_id = Integer(object["teacher_id"])
        teacher_name = String(object["teacher_name"])

        # Conditions for find existing teacher
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:server_id] = server_id
        conditions[:name] = teacher_name

        # Try to find existing teahcer first
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

      rescue Exception => e
        Rails.logger.error(e)
        next
      end

    end
  end

end
