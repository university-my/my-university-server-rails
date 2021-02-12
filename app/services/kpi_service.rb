# frozen_string_literal: true

require 'net/http'
require 'json'

module KpiService
  #
  # Classrooms
  #

  def self.import_rooms(classrooms, university)
    auditoriums = []
    classrooms.each do |classroom|
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
      auditoriums << auditorium unless auditoriums.include?(auditorium)
    end

    auditoriums
  end

  #
  # Import records for group from KPI API
  #

  def self.import_records_for_group(group, selected_pair_date)
    # Get current week
    current_week = week_for_selected_date(selected_pair_date)

    # Perform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/groups/#{group.server_id}/lessons"
    json = ApplicationRecord.perform_request(url)

    # JSON may be nil
    return if json.nil?

    # There a may not be any data
    data = json['data']
    return if data.nil?

    university = University.kpi

    groups = [group]

    # Save records
    data.each do |object|
      # Get data from JSON
      time = object['time_start']
      pair_name = object['lesson_number']
      name_string = object['lesson_full_name']
      kind = object['lesson_type']
      day_number = object['day_number'].to_i
      lesson_week = object['lesson_week'].to_i

      # Teacher
      teachers = object['teachers']

      # Classrooms
      classrooms = object['rooms']

      begin
        # Convert to int before find request

        # Teacher
        teacher = nil
        if (teacher_hash = teachers.first)
          teacher_id = teacher_hash['teacher_id'].to_i
          teacher = Teacher.find_by(university_id: university.id, server_id: teacher_id)
        end

        # Classrooms
        auditoriums = import_rooms(classrooms, university)

        # Calculate pair date
        year = selected_pair_date.year
        week = selected_pair_date.cweek
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
        pair_start_date = (start_date.strftime('%F') + ' ' + pair_time.to_s(:time)).to_datetime

        # Don't update old records because we don't want to override it
        current_date = Date.today.beginning_of_day
        next if start_date < current_date

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:pair_start_date] = pair_start_date
        conditions[:name] = name_string
        conditions[:pair_name] = pair_name
        conditions[:kind] = kind
        conditions[:time] = time

        # Try to find existing record first
        record = Record.find_by(conditions)

        if record.nil?
          # New record
          record = Record.new
        end

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
        record.groups << group unless record.groups.include?(group)

        # Save or update Discipline
        discipline = save_discipline(name_string, auditoriums.first, groups, teacher)
        record.discipline = discipline

        unless record.save
          # Go to the next iteration if record can't be saved
          Rails.logger.error(record.errors.full_messages)
          next
        end
      rescue StandardError => e
        Rails.logger.error(e)
        next
      end
    end

    # Update `updated_at` date of Group
    group.touch(:updated_at)
    Rails.logger.error(errors.full_messages) unless group.save
  end

  #
  # Import records for teacher from KPI API
  #

  def self.import_records_for_teacher(teacher, selected_pair_date)
    # Get current week
    current_week = week_for_selected_date(selected_pair_date)

    # Perform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/teachers/#{teacher.server_id}/lessons"
    json = ApplicationRecord.perform_request(url)

    # JSON may be nil
    return if json.nil?

    # There a may not be any data
    data = json['data']
    return if data.nil?

    university = University.kpi

    # Save records
    data.each do |object|
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
        group_ids = []
        groups.each do |group|
          if (id = group['group_id'].to_i)
            group_ids.push(id)
          end
        end
        groups = Group.where(university: university, server_id: group_ids)

        # Classrooms
        auditoriums = import_rooms(classrooms, university)

        # Calculate pair date
        year = selected_pair_date.year
        week = selected_pair_date.cweek
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
        pair_start_date = (start_date.strftime('%F') + ' ' + pair_time.to_s(:time)).to_datetime

        # Don't update old records because we don't want to override it
        current_date = Date.today.beginning_of_day
        next if start_date < current_date

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:pair_start_date] = pair_start_date
        conditions[:name] = name_string
        conditions[:pair_name] = pair_name
        conditions[:kind] = kind
        conditions[:time] = time
        conditions[:teacher_id] = teacher.id

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
        record.name = name_string
        record.kind = kind
        record.university = university

        # Associations
        record.teacher = teacher
        record.auditorium = auditoriums.first

        # Push only unique groups
        groups.each do |group|
          record.groups << group unless record.groups.include?(group)
        end

        # Save or update Discipline
        discipline = save_discipline(name_string, auditoriums.first, groups, teacher)
        record.discipline = discipline

        unless record.save
          # Go to the next iteration if record can't be saved
          Rails.logger.error(record.errors.full_messages)
          next
        end
      rescue StandardError => e
        Rails.logger.error(e)
        next
      end
    end

    # Update `updated_at` date of Teacher
    teacher.touch(:updated_at)
    Rails.logger.error(errors.full_messages) unless teacher.save
  end

  #
  # Import groups from KPI API
  #

  # bin/rails runner 'KpiService.import_groups'
  def self.import_groups
    groups_total_count = KpiService.groups_count

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
  def self.groups_count
    # Perform network request and parse JSON
    url = 'https://api.rozklad.org.ua/v2/groups'
    json = ApplicationRecord.perform_request(url)

    return 0 if json.nil?

    total_count = json['meta']['total_count']
    teachers_total_count = Integer(total_count)

    teachers_total_count
  end

  # Make request with offset parameter and parse JSON
  def self.get_groups(offset)
    # Perform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/groups/?filter={%27limit%27:100,%27offset%27:#{offset}}"
    json = ApplicationRecord.perform_request(url)
    json
  end

  # Serialize groups from JSON and save to database
  def self.save_groups_from(json)
    data = json['data']

    # This groups for SumDU
    university = University.kpi

    data.each do |object|
      # Convert before save
      server_id = Integer(object['group_id'])
      group_name = String(object['group_full_name'])

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
    rescue StandardError => e
      Rails.logger.error(e)
      next
    end
  end

  #
  # Get current week from KPI API
  #

  # Request current week from KPI API
  def self.current_week
    # Perform network request and parse JSON
    url = 'https://api.rozklad.org.ua/v2/weeks'
    json = ApplicationRecord.perform_request(url)

    return 1 if json.nil?

    week = json['data']

    week
  end

  # Week for current date
  # What we have: Selected date
  # What we need: Week number for selected date
  def self.week_for_selected_date(selected_pair_date)
    remainder_of_division = selected_pair_date.cweek % 2
    if remainder_of_division.zero?
      1
    else
      2
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
    teachers_total_count = KpiService.teachers_count

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
  def self.teachers_count
    # Perform network request and parse JSON
    url = 'https://api.rozklad.org.ua/v2/teachers'
    json = ApplicationRecord.perform_request(url)

    return if json.nil?

    total_count = json['meta']['total_count']
    teachers_total_count = Integer(total_count)

    teachers_total_count
  end

  # Make request with offset parameter and parse JSON
  def self.get_teachers(offset)
    # Perform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/teachers/?filter={%27limit%27:100,%27offset%27:#{offset}}"
    json = ApplicationRecord.perform_request(url)

    json
  end

  # Serialize teachers from JSON and save to database
  def self.save_teachers_from(json)
    data = json['data']

    # This groups for SumDU
    university = University.kpi

    data.each do |object|
      # Convert before save
      server_id = Integer(object['teacher_id'])
      teacher_name = String(object['teacher_name'])

      # Conditions for find existing teacher
      conditions = {}
      conditions[:university_id] = university.id
      conditions[:server_id] = server_id
      conditions[:name] = teacher_name

      # Try to find existing Teacher first
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
  # Import Discipline
  #
  # @param [String] name
  # @param [Auditorium] auditorium
  # @param [Group] groups
  # @param [Teacher] teacher
  def self.save_discipline(name, auditorium, groups, teacher)
    university = University.kpi
    discipline = Discipline.save_or_update(name, university, auditorium, groups, teacher)
    discipline
  end

  def self.import_records_for_auditorium(auditorium, selected_pair_date)
    # Do nothing here
  end
end
