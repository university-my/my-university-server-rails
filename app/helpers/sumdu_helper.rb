require 'net/http'
require 'json'

module SumduHelper

  #
  # Import records for auditorium from SumDU API
  #

  def self.importRecordsForAuditorium(auditorium)
    # Update `updated_at` date of Auditorium
    auditorium.touch(:updated_at)
    unless auditorium.save
      Rails.logger.error(errors.full_messages)
    end
    
    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_aud=#{auditorium.server_id}"

    # Init URI
    uri = URI(url + query)
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      auditorium.errors.add(:base, error_message)
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      auditorium.errors.add(:base, error_message)
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    # Delete old records
    Record.where('auditorium_id': auditorium.id).where("updated_at < ?", DateTime.current - 2.day).destroy_all

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
        groups = Group.where(name: stripedNames)

        # Auditorium
        # Convert to int before find request
        teacherID = kodFio.to_i
        teacher = Teacher.where(server_id: teacherID).first

        # Pair start date
        startDate = dateString.to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:start_date] = startDate
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
          record.start_date = startDate
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind

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
          record.start_date = startDate
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind

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
  end

  #
  # Import records for group from SumDU API
  #

  def self.importRecordsForGroup(group)
    # Update `updated_at` date of Group
    group.touch(:updated_at)
    unless group.save
      Rails.logger.error(errors.full_messages)
    end
    
    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_grp=#{group.server_id}"

    # Init URI
    uri = URI(url + query)
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      group.errors.add(:base, error_message)
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      group.errors.add(:base, error_message)
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    # Delete old records
    Record.joins(:groups).where('groups.id': group.id).where("records.updated_at < ?", DateTime.current - 2.day).destroy_all

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
        auditorium = Auditorium.find_by(server_id: auditoriumID)

        # Teacher
        teacherID = kodFio.to_i
        teacher = Teacher.find_by(server_id: teacherID)

        # Pair start date
        startDate = dateString.to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:start_date] = startDate
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
          record.start_date = startDate
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind

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
          record.start_date = startDate
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind

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
  end

  #
  # Import records for teacher from SumDU API
  #

  def self.importRecordsForTeacher(teacher)
    # Update `updated_at` date of Teacher
    teacher.touch(:updated_at)
    unless teacher.save
      Rails.logger.error(errors.full_messages)
    end
    
    url = 'http://schedule.sumdu.edu.ua/index/json?method=getSchedules'
    query = "&id_fio=#{teacher.server_id}"

    # Init URI
    uri = URI(url + query)
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      teacher.errors.add(:base, error_message)
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      teacher.errors.add(:base, error_message)
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    # Delete old records
    Record.where('teacher_id': teacher.id).where("updated_at < ?", DateTime.current - 2.day).destroy_all

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
        groups = Group.where(name: stripedNames)

        # Auditorium
        # Convert to int before find request
        auditoriumID = kodAud.to_i
        auditorium = Auditorium.where(server_id: auditoriumID).first

        # Pair start date
        startDate = dateString.to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:start_date] = startDate
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
          record.start_date = startDate
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind

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
          record.start_date = startDate
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind

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
  end

  #
  # Import auditorums from SumDU API
  #

  # # bin/rails runner 'SumduHelper.importAuditoriums'
  def self.importAuditoriums

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getAuditoriums")
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

    # Parse JSON
    json = JSON.parse(response.body)

    # Delete before save
    Auditorium.destroy_all

    # This groups for SumDU
    university = University.find_by(url: "sumdu")

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        auditoriumName = object[1]

        # Save new auditorium
        auditorium = Auditorium.new
        auditorium.server_id = serverID
        auditorium.name = auditoriumName
        auditorium.university = university

        unless auditorium.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(auditorium.errors.full_messages)
          next
        end
        
      rescue Exception => e
        Rails.logger.error(e)
        next
      end
    end
  end

  #
  # Import groups from SumDU API
  #

  # bin/rails runner 'SumduHelper.importGroups'
  def self.importGroups

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getGroups")
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

    # Parse JSON
    json = JSON.parse(response.body)

    # This groups for SumDU
    university = University.find_by(url: "sumdu")

    # Delete before save
    Group.where(university_id: university.id).destroy_all

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        groupName = object[1]

        # Save new group
        group = Group.new
        group.server_id = serverID
        group.name = groupName
        group.university = university
        
        unless group.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(group.errors.full_messages)
          next
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

  # Import from SumDU
  # bin/rails runner 'SumduHelper.importTeachers'
  def self.importTeachers

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getTeachers")
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

    # Parse JSON
    json = JSON.parse(response.body)

    # This teachers for SumDU
    university = University.find_by(url: "sumdu")

    # Delete before save
    Teacher.where(university_id: university.id).destroy_all

    for object in json do

      begin
        # Convert to int before save
        serverID = Integer(object[0])
        teacherName = object[1]

        # Save new teacher
        teacher = Teacher.new
        teacher.server_id = serverID
        teacher.name = teacherName
        teacher.university = university

        unless teacher.save
          # Go to the next iteration if can't be saved
          Rails.logger.error(teacher.errors.full_messages)
          next
        end

      rescue Exception => e
        Rails.logger.error(e)
        next
      end
    end
  end

end