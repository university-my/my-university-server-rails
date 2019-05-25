require 'net/http'
require 'json'

module SumduHelper

  #
  # Import records for auditorium from SumDU API
  #

  def self.import_records_for_auditorium(auditorium)

    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_aud=#{auditorium.server_id}"

    # Peform network request and parse JSON
    json = ApplicationRecord.perform_request(url + query)

    university = University.find_by(url: "sumdu")

    # Delete old records
    Record.where(university_id: university.id, auditorium_id: auditorium.id).where("updated_at < ?", DateTime.current - 2.day).destroy_all

    # Save records
    for object in json do

      # Get data from JSON
      dateString = object['DATE_REG']
      time = object['TIME_PAIR']
      pairName = object['NAME_PAIR']
      nameString = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Teacher
      kodFio = object['KOD_FIO']

      # Group
      nameGroup = object['NAME_GROUP']

      begin
        # Split groups into array
        groupNames = nameGroup.split(',')

        # Groups
        stripedNames = Array.new
        for groupName in groupNames do
          stripedNames.push(groupName.strip)
        end
        groups = Group.where(university_id: university.id, name: stripedNames)

        # Auditorium
        # Convert to int before find request
        teacherID = kodFio.to_i
        teacher = Teacher.where(university_id: university.id, server_id: teacherID).first

        # Pair start date
        start_date = dateString.to_datetime

        # Get pair date and time
        pair_time = time.split('-').first
        pair_start_date  = (dateString + ' ' + pair_time).to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:start_date] = start_date
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:reason] = reason
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
          record.pair_name = pairName
          record.name = nameString
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

          # Try to save record
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
          record.pair_name = pairName
          record.name = nameString
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

    # Update `updated_at` date of Auditorium
    auditorium.touch(:updated_at)
    unless auditorium.save
      Rails.logger.error(errors.full_messages)
    end

  end

  #
  # Import records for group from SumDU API
  #

  def self.import_records_for_group(group)

    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_grp=#{group.server_id}"

    # Peform network request and parse JSON
    json = ApplicationRecord.perform_request(url + query)

    university = University.find_by(url: "sumdu")

    # Delete old records
    Record.joins(:groups).where(university_id: university.id, 'groups.id': group.id).where("records.updated_at < ?", DateTime.current - 2.day).destroy_all

    # Save records
    for object in json do

      # Get data from JSON
      dateString = object['DATE_REG']
      time = object['TIME_PAIR']
      pairName = object['NAME_PAIR']
      nameString = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Auditorium
      kodAud = object['KOD_AUD']

      # Teacher
      kodFio = object['KOD_FIO']

      begin
        # Convert to int before find request

        # Auditorium
        auditoriumID = kodAud.to_i
        auditorium = Auditorium.find_by(university_id: university.id, server_id: auditoriumID)

        # Teacher
        teacherID = kodFio.to_i
        teacher = Teacher.find_by(university_id: university.id, server_id: teacherID)

        # Pair start date
        start_date = dateString.to_datetime

        # Get pair date and time
        pair_time = time.split('-').first
        pair_start_date  = (dateString + ' ' + pair_time).to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:start_date] = start_date
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:reason] = reason
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
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind
          record.university = university

          # Associations
          record.auditorium = auditorium
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
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind
          record.university = university

          # Associations
          record.auditorium = auditorium
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
  # Import records for teacher from SumDU API
  #

  def self.import_records_for_teacher(teacher)

    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_fio=#{teacher.server_id}"

    # Peform network request and parse JSON
    json = ApplicationRecord.perform_request(url + query)

    university = University.find_by(url: "sumdu")

    # Delete old records
    Record.where(university_id: university.id, teacher_id: teacher.id).where("updated_at < ?", DateTime.current - 2.day).destroy_all

    # Save records
    for object in json do

      # Get data from JSON
      dateString = object['DATE_REG']
      time = object['TIME_PAIR']
      pairName = object['NAME_PAIR']
      nameString = object['ABBR_DISC']
      reason = object['REASON']
      kind = object['NAME_STUD']

      # Auditorium
      kodAud = object['KOD_AUD']

      # Group
      nameGroup = object['NAME_GROUP']

      begin
        # Split groups into array
        groupNames = nameGroup.split(',')

        # Groups
        stripedNames = Array.new
        for groupName in groupNames do
          stripedNames.push(groupName.strip)
        end
        groups = Group.where(university_id: university.id, name: stripedNames)

        # Auditorium
        # Convert to int before find request
        auditoriumID = kodAud.to_i
        auditorium = Auditorium.where(university_id: university.id, server_id: auditoriumID).first

        # Pair start date
        start_date = dateString.to_datetime

        # Get pair date and time
        pair_time = time.split('-').first
        pair_start_date  = (dateString + ' ' + pair_time).to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:start_date] = start_date
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:reason] = reason
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
          record.pair_name = pairName
          record.name = nameString
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

          unless record.save
            # Go to the next iteration if record can't be saved
            Rails.logger.error(record.errors.full_messages)
            next
          end

        else
          record.start_date = start_date
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pairName
          record.name = nameString
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
  # Import auditorums from SumDU API
  #

  # # bin/rails runner 'SumduHelper.import_auditoriums'
  def self.import_auditoriums

    # Peform network request and parse JSON
    url = "http://schedule.sumdu.edu.ua/index/json?method=getAuditoriums"
    json = ApplicationRecord.perform_request(url)

    # This groups for SumDU
    university = University.find_by(url: "sumdu")

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        auditoriumName = object[1]
        
        # Conditions for find existing auditorium
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:server_id] = serverID
        conditions[:name] = auditoriumName
        
        # Try to find existing auditorium first
        auditorium = Auditorium.find_by(conditions)
        
        if auditorium.nil?
          # Save new auditorium
          auditorium = Auditorium.new
          auditorium.server_id = serverID
          auditorium.name = auditoriumName
          auditorium.university = university
          
          unless auditorium.save
            # Go to the next iteration if can't be saved
            p auditorium.errors.full_messages
            Rails.logger.error(auditorium.errors.full_messages)
            next
          end
        end
        
      rescue Exception => e
        p e
        Rails.logger.error(e)
        next
      end
    end
  end

  #
  # Import groups from SumDU API
  #

  # bin/rails runner 'SumduHelper.import_groups'
  def self.import_groups

    # Peform network request and parse JSON
    url = "http://schedule.sumdu.edu.ua/index/json?method=getGroups"
    json = ApplicationRecord.perform_request(url)

    # This groups for SumDU
    university = University.find_by(url: "sumdu")

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        groupName = object[1]

        # Conditions for find existing group
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:server_id] = serverID
        conditions[:name] = groupName

        # Try to find existing group first
        group = Group.find_by(conditions)

        if group.nil?
          # Save new group
          group = Group.new
          group.server_id = serverID
          group.name = groupName
          group.university = university
          
          unless group.save
            # Go to the next iteration if can't be saved
            p group.errors.full_messages
            Rails.logger.error(group.errors.full_messages)
            next
          end
        end
        
      rescue Exception => e 
        p e
        Rails.logger.error(e)
        next
      end
    end
  end

  #
  # Import teachers from SumDU API
  #

  # bin/rails runner 'SumduHelper.import_teachers'
  def self.import_teachers

    # Peform network request and parse JSON
    url = "http://schedule.sumdu.edu.ua/index/json?method=getTeachers"
    json = ApplicationRecord.perform_request(url)

    # This teachers for SumDU
    university = University.find_by(url: "sumdu")

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        teacherName = object[1]

        # Conditions for find existing teacher
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:server_id] = serverID
        conditions[:name] = teacherName
        
        # Try to find existing teahcer first
        teacher = Teacher.find_by(conditions)

        if teacher.nil?
          # Save new teacher
          teacher = Teacher.new
          teacher.server_id = serverID
          teacher.name = teacherName
          teacher.university = university

          unless teacher.save
            # Go to the next iteration if can't be saved
            p teacher.errors.full_messages
            Rails.logger.error(teacher.errors.full_messages)
            next
          end
        end

      rescue Exception => e
        p e
        Rails.logger.error(e)
        next
      end
      
    end
  end

end