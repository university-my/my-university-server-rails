require 'net/http'
require 'json'

class SumduService

  #
  # Import records for auditorium from SumDU API
  #
  def self.import_records_for_auditorium(auditorium, date)

    start_date = date.strftime("%d.%m.%Y")
    end_date = (date + 1.day).strftime("%d.%m.%Y")

    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_aud=#{auditorium.server_id}&date_beg=#{start_date}&date_end=#{end_date}"

    # Peform network request and parse JSON
    json = ApplicationRecord.perform_request(url + query)

    university = University.sumdu

    # Save records
    for object in json do

      # Get data from JSON
      date_string = object['DATE_REG']
      time = object['TIME_PAIR']
      pair_name = object['NAME_PAIR']
      name_string = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Teacher
      kod_fio = object['KOD_FIO']

      # Group
      name_group = object['NAME_GROUP']

      begin
        # Split groups into array
        group_names = name_group.split(',')

        # Groups
        striped_names = Array.new
        for group_name in group_names do
          striped_names.push(group_name.strip)
        end
        groups = Group.where(university: university, name: striped_names)

        # Teacher
        # Convert to int before find request
        teacher_id = kod_fio.to_i
        teacher = Teacher.where(university: university, server_id: teacher_id).first

        # Get pair date and time
        pair_time = time.split('-').first
        pair_start_date  = (date_string + ' ' + pair_time).to_datetime

        # Save or update Record
        save_or_update_record(pair_start_date, time, name_string, pair_name, reason, kind, auditorium, teacher, groups, university)

      rescue StandardError => e
        Rails.logger.error(e)
        next
      end
    end

    # Update `updated_at` date of Auditorium
    auditorium.touch(:updated_at)
    unless auditorium.save
      Rails.logger.error(errors.full_messages)
    end
  end

  #
  # Import records for group from SumDU API
  #
  def self.import_records_for_group(group, date)

    start_date = date.strftime("%d.%m.%Y")
    end_date = (date + 1.day).strftime("%d.%m.%Y")

    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_grp=#{group.server_id}&date_beg=#{start_date}&date_end=#{end_date}"

    # Peform network request and parse JSON
    json = ApplicationRecord.perform_request(url + query)

    university = University.sumdu

    # Save records
    for object in json do

      # Get data from JSON
      date_string = object['DATE_REG']
      time = object['TIME_PAIR']
      pair_name = object['NAME_PAIR']
      name_string = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Auditorium
      kod_aud = object['KOD_AUD']

      # Teacher
      kod_fio = object['KOD_FIO']

      begin
        # Convert to int before find request

        # Auditorium
        auditorium_id = kod_aud.to_i
        auditorium = Auditorium.find_by(university_id: university.id, server_id: auditorium_id)

        # Teacher
        teacher_id = kod_fio.to_i
        teacher = Teacher.find_by(university_id: university.id, server_id: teacher_id)

        # Get pair date and time
        pair_time = time.split('-').first
        pair_start_date  = (date_string + ' ' + pair_time).to_datetime

        # Save or update Record
        save_or_update_record(pair_start_date, time, name_string, pair_name, reason, kind, auditorium, teacher, [group], university)

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
  # Import records for teacher from SumDU API
  #
  def self.import_records_for_teacher(teacher, date)

    start_date = date.strftime("%d.%m.%Y")
    end_date = (date + 1.day).strftime("%d.%m.%Y")

    # TODO: Check dates

    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_fio=#{teacher.server_id}&date_beg=#{start_date}&date_end=#{end_date}"

    # Peform network request and parse JSON
    json = ApplicationRecord.perform_request(url + query)

    university = University.sumdu

    # Save records
    for object in json do

      # Get data from JSON
      date_string = object['DATE_REG']
      time = object['TIME_PAIR']
      pair_name = object['NAME_PAIR']
      name_string = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Auditorium
      kod_aud = object['KOD_AUD']

      # Group
      name_group = object['NAME_GROUP']

      begin
        # Split groups into array
        group_names = name_group.split(',')

        # Groups
        striped_names = Array.new
        for group_name in group_names do
          striped_names.push(group_name.strip)
        end
        groups = Group.where(university: university, name: striped_names)

        # Auditorium
        # Convert to int before find request
        auditorium_id = kod_aud.to_i
        auditorium = Auditorium.where(university: university, server_id: auditorium_id).first

        # Get pair date and time
        pair_time = time.split('-').first
        pair_start_date  = (date_string + ' ' + pair_time).to_datetime

        # Save or update Record
        save_or_update_record(pair_start_date, time, name_string, pair_name, reason, kind, auditorium, teacher, groups, university)

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
  # Import auditoriums from SumDU API
  #
  # # bin/rails runner 'SumduService.import_auditoriums'
  def self.import_auditoriums

    # Peform network request and parse JSON
    url = "http://schedule.sumdu.edu.ua/index/json?method=getAuditoriums"
    json = ApplicationRecord.perform_request(url)

    # This groups for SumDU
    university = University.sumdu

    for object in json do

      begin
        # Convert to int before save
        server_id = Integer(object[0])
        auditorium_name = object[1]

        # Building name
        if auditorium_name.include? "-"
          building_name = auditorium_name.split('-').first
        elsif auditorium_name.include? "_"
          building_name = auditorium_name.split('_').first
        end
        if building_name
          building = Building.where(university: university)
          .where('name LIKE ?', "#{building_name}%").first
        end

        # Conditions for find existing auditorium
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:server_id] = server_id
        conditions[:name] = auditorium_name

        # Try to find existing auditorium first
        auditorium = Auditorium.find_by(conditions)

        if auditorium.nil?
          auditorium = Auditorium.new
        end
        auditorium.server_id = server_id
        auditorium.name = auditorium_name
        auditorium.university = university

        if auditorium.building.nil?
          # Assign building if empty
          auditorium.building = building
        end

        unless auditorium.save
          # Go to the next iteration if can't be saved
          Rails.logger.error auditorium.errors.full_messages
          next
        end

      rescue Exception => e
        Rails.logger.error e
        next
      end
    end
  end

  #
  # Import groups from SumDU API
  #
  # bin/rails runner 'SumduService.import_groups'
  def self.import_groups

    # Peform network request and parse JSON
    url = "http://schedule.sumdu.edu.ua/index/json?method=getGroups"
    json = ApplicationRecord.perform_request(url)

    # This groups for SumDU
    university = University.sumdu

    for object in json do

      begin
        # Convert to int before save
        server_id = Integer(object[0])
        group_name = object[1]

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
  # Import teachers from SumDU API
  #
  # bin/rails runner 'SumduService.import_teachers'
  def self.import_teachers

    # Peform network request and parse JSON
    url = "http://schedule.sumdu.edu.ua/index/json?method=getTeachers"
    json = ApplicationRecord.perform_request(url)

    # This teachers for SumDU
    university = University.sumdu

    for object in json do

      begin
        # Convert to int before save
        server_id = Integer(object[0])
        teacher_name = object[1]

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

  #
  # Record
  #
  def self.save_or_update_record(pair_start_date, time, name_string, pair_name, reason, kind, auditorium, teacher, groups, university)
    # Conditions for find existing pair
    conditions = {}
    conditions[:university_id] = university.id
    conditions[:pair_start_date] = pair_start_date
    conditions[:name] = name_string
    conditions[:pair_name] = pair_name
    conditions[:reason] = reason
    conditions[:kind] = kind
    conditions[:time] = time

    # Try to find existing record first
    record = Record.find_by(conditions)

    if record.nil?
      # Save new record
      record = Record.new
      record.pair_start_date = pair_start_date
      record.time = time
      record.pair_name = pair_name
      record.name = name_string
      record.reason = reason
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
      # Update record
      record.pair_start_date = pair_start_date
      record.time = time
      record.pair_name = pair_name
      record.name = name_string
      record.reason = reason
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
  end

  #
  # Import Discipline
  #
  def self.save_discipline(name, auditorium, groups, teacher)
    university = University.sumdu
    discipline = Discipline.save_or_update(name, university, auditorium, groups, teacher)
    return discipline
  end

end
