require 'net/http'
require 'json'

module KpiHelper  

  #
  # Import records for group from KPI API
  #

  def self.import_records_for_group(group)
    # Get current week from API
    currentWeek = get_current_week

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/groups/#{group.server_id}/lessons"
    json = ApplicationRecord.perform_request(url)
    
    if json.nil?
      return
    end
    
    data = json["data"]

    university = University.find_by(url: "kpi")

    # Delete old records
    Record.joins(:groups).where(university_id: university.id, 'groups.id': group.id).where("records.updated_at < ?", DateTime.current - 2.day).destroy_all

    currentDate = Date.current

    # Save records
    for object in data do

      # Get data from JSON
      time = object['time_start']
      pairName = object['lesson_number']
      nameString = object['lesson_full_name']
      kind = object['lesson_type']
      reason = object['lesson_room']
      dayNumber = object['day_number'].to_i
      lessonWeek = object['lesson_week'].to_i

      if currentWeek != lessonWeek
        # Skip if not current week
        next
      end

      # Teahcer
      teachers = object['teachers']

      begin
        # Convert to int before find request

        # Teacher
        teacher = nil
        if teacherHash = teachers.first
          teacherID = teacherHash['teacher_id'].to_i
          teacher = Teacher.find_by(university_id: university.id, server_id: teacherID)
        end

        startDate = KpiHelper.get_date(currentWeek, dayNumber, lessonWeek)

        # Skip old records
        if startDate < currentDate
          next
        end

        # Get pair date and time
        pair_time = time.to_time
        pair_start_date  = (startDate.strftime("%F") + ' ' + pair_time.to_s(:time)).to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
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
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind
          record.university = university

          # Associations
          record.teacher = teacher
          
          # Push only unique groups
          unless record.groups.include?(group)
           record.groups << group
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            p record.errors.full_messages
            Rails.logger.error(record.errors.full_messages)
            next
          end
          
        else
          # Update record
          record.start_date = startDate
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind
          record.university = university

          # Associations
          record.teacher = teacher
          
          # Push only unique groups
          unless record.groups.include?(group)
           record.groups << group
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            p record.errors.full_messages
            Rails.logger.error(record.errors.full_messages)
            next
          end
        end

      rescue Exception => e
        p e
        Rails.logger.error(e)
        next
      end
    end

    # Update `updated_at` date of Group
    group.touch(:updated_at)
    unless group.save
      p errors.full_messages
      Rails.logger.error(errors.full_messages)
    end
  end

  #
  # Import records for teacher from KPI API
  #

  def self.import_records_for_teacher(teacher)
    # Get current week from API
    currentWeek = get_current_week

    # Peform network request and parse JSON
    url = "https://api.rozklad.org.ua/v2/teachers/#{teacher.server_id}/lessons"
    json = ApplicationRecord.perform_request(url)
    
    if json.nil?
      return
    end
    
    data = json["data"]

    university = University.find_by(url: "kpi")

    # Delete old records
    Record.where(university_id: university.id, teacher_id: teacher.id).where("updated_at < ?", DateTime.current - 2.day).destroy_all

    currentDate = DateTime.now.change({ hour: 0, min: 0, sec: 0 })

    # Save records
    for object in data do

      # Get data from JSON
      time = object['time_start']
      pairName = object['lesson_number']
      nameString = object['lesson_full_name']
      kind = object['lesson_type']
      reason = object['lesson_room']
      dayNumber = object['day_number'].to_i
      lessonWeek = object['lesson_week'].to_i

      if currentWeek != lessonWeek
        # Skip if not current week
        next
      end

      # Groups
      groups = object['groups']

      begin
        # Group
        groupIDs = Array.new
        for group in groups do
          if id = group['group_id'].to_i
            groupIDs.push(id)
          end
        end
        groups = Group.where(university_id: university.id, server_id: groupIDs)

        # Pair start date
        startDate = KpiHelper.get_date(currentWeek, dayNumber, lessonWeek)

        # Get pair date and time
        pair_time = time.to_time
        pair_start_date  = (startDate.strftime("%F") + ' ' + pair_time.to_s(:time)).to_datetime

        # Skip old records
        if startDate < currentDate
          next
        end

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:start_date] = startDate
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:reason] = reason
        conditions[:kind] = kind
        conditions[:time] = time
        conditions[:teacher_id] = teacher.id

        # Try to find existing record first
        record = Record.find_by(conditions)

        if record.nil?
          # Save new record
          record = Record.new
          record.start_date = startDate
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind
          record.university = university

          # Associations
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
            next
          end

        else
          record.start_date = startDate
          record.pair_start_date = pair_start_date
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.reason = reason
          record.kind = kind
          record.university = university

          # Associations
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
            next
          end
        end
        
      rescue Exception => e
        p e
        Rails.logger.error(e)
        next
      end
    end

    # Update `updated_at` date of Teacher
    teacher.touch(:updated_at)
    unless teacher.save
      p errors.full_messages
      Rails.logger.error(errors.full_messages)
    end    
  end


  #
  # Import groups from KPI API
  #

  # bin/rails runner 'KpiHelper.import_groups'
  def self.import_groups
    groupsTotalCount = KpiHelper.get_groups_count

    offset = 0

    while offset < groupsTotalCount
      # Get json with groups from API
      json = KpiHelper.get_groups(offset)

      # Save to database
      KpiHelper.save_groups_from(json)

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

    totalCount = json["meta"]["total_count"]
    teachersTotalCount = Integer(totalCount)

    return teachersTotalCount
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
    university = University.find_by(url: "kpi")
    
    for object in data do

      begin
        # Convert before save
        serverID = Integer(object["group_id"])
        groupName = String(object["group_full_name"])
        
        # Save new group
        group = Group.new
        group.server_id = serverID
        group.name = groupName
        
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
            p group.errors.full_messages
            
            # Go to the next iteration if can't be saved
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

  def self.get_date(currentWeek, dayNumber, lessonWeek)

    # Params for generate date
    recordDate = DateTime.current.beginning_of_day

    # Shift from Sunday to Monday
    if recordDate.wday == 0
      recordDate = recordDate.next_week.beginning_of_week
    end

    # Current week day
    currentWeekDay = recordDate.wday

    # Calculate pair date
    dayShift = 0
    if currentWeekDay > dayNumber
      dayShift = currentWeekDay - dayNumber
      recordDate = recordDate - dayShift.days

    elsif currentWeekDay < dayNumber
      dayShift = dayNumber - currentWeekDay 
      recordDate = recordDate + dayShift.days
    end
    return recordDate
  end

  #
  # Import teachers from KPI API
  #

  # Import from KPI
  # bin/rails runner 'KpiHelper.import_teachers'
  def self.import_teachers
    teachersTotalCount = KpiHelper.get_teachers_count

    offset = 0

    while offset < teachersTotalCount
      # Get json with teachers from API
      json = KpiHelper.get_teachers(offset)

      # Save to database
      KpiHelper.save_teachers_from(json)

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

    totalCount = json["meta"]["total_count"]
    teachersTotalCount = Integer(totalCount)

    return teachersTotalCount
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
    university = University.find_by(url: "kpi")
    
    for object in data do

      begin
        # Convert before save
        serverID = Integer(object["teacher_id"])
        teacherName = String(object["teacher_name"])
        
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