module KPIHelper

  #
  # Import records for group from KPI API
  #

  def self.importRecordsForGroup(group)
    # Update `updated_at` date of Group
    group.touch(:updated_at)
    unless group.save
      logger.error(errors.full_messages)
    end

    url = "https://api.rozklad.org.ua/v2/groups/#{server_id}/lessons"
    # Init URI
    uri = URI(url)

    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)
    data = json["data"]

    # Delete old records
    Record.joins(:groups).where('groups.id': group.id).where("records.updated_at < ?", DateTime.current - 2.day).destroy_all

    # Save records
    for object in data do

      # Get data from JSON
      time = object['time_start']
      pairName = object['lesson_number']
      nameString = object['lesson_full_name']
      kind = object['lesson_type']
      dayNumber = object['day_number']
      lessonWeek = object['lesson_week']

      begin
        # Convert to int before find request
        UniversitiesHelper.getDate(time, dayNumber, lessonWeek)

        # Conditions for find existing pair
        conditions = {}
        conditions[:name] = nameString
        conditions[:pair_name] = pairName
        conditions[:kind] = kind
        conditions[:time] = time

        # Try to find existing record first
        record = Record.find_by(conditions)

        if record.nil?
          # Save new record
          record = Record.new
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.kind = kind
          
          # Push only unique groups
          unless record.groups.include?(group)
           record.groups << group
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            logger.error(record.errors.full_messages)
            next
          end
          
        else
          # Update record
          record.time = time
          record.pair_name = pairName
          record.name = nameString
          record.kind = kind
          
          # Push only unique groups
          unless record.groups.include?(group)
           record.groups << group
         end

         unless record.save
            # Go to the next iteration if record can't be saved
            logger.error(record.errors.full_messages)
            next
          end
        end

      rescue Exception => e
        logger.error(e)
        next
      end
    end
  end

  #
  # Import groups from KPI API
  #

  # bin/rails runner 'KPIHelper.importGroups'
  def self.importGroups
    groupsTotalCount = KPIHelper.getGroupsCount

    # This groups for KPI
    university = University.find_by(url: "kpi")

    # Delete before save
    Group.where(university_id: university.id).destroy_all

    offset = 0

    while offset < groupsTotalCount
      # Get json with groups from API
      json = KPIHelper.getGroups(offset)

      # Save to database
      KPIHelper.saveGroupsFrom(json)

      offset += 100
    end
  end


   # Make request to API for get total count of all groups
   def self.getGroupsCount
    # Init URI
    uri = URI("https://api.rozklad.org.ua/v2/groups")
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    totalCount = json["meta"]["total_count"]
    teachersTotalCount = Integer(totalCount)

    return teachersTotalCount
  end


  # Make request with offset parameter and parse JSON
  def self.getGroups(offset)
     # Init URI
     uri = URI("https://api.rozklad.org.ua/v2/groups/?filter={%27limit%27:100,%27offset%27:#{offset}}")
     if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

     # Perform request
     response = Net::HTTP.get_response(uri)
     if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    return json
  end


  # Serialize groups from JSON and save to database
  def self.saveGroupsFrom(json)

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
        group.university = university

        unless group.save
          # Go to the next iteration if can't be saved
          logger.error(group.errors.full_messages)
          next
        end

      rescue Exception => e
        logger.error(e)
        next
      end
    end
  end

  #
  # Get current week from KPI API
  #

  # Request current week from KPI API
  def self.getCurrentWeek
    # Init URI
    uri = URI("https://api.rozklad.org.ua/v2/weeks")
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)
    week = json['data']

    return week
  end

  #
  # Import teachers from KPI API
  #

  # Import from KPI
  # bin/rails runner 'KPIHelper.importTeachers'
  def self.importTeachers
    teachersTotalCount = KPIHelper.getTeachersCount

    # This teachers for KPI
    university = University.find_by(url: "kpi")

    # Delete before save
    Teacher.where(university_id: university.id).destroy_all

    offset = 0

    while offset < teachersTotalCount
      # Get json with teachers from API
      json = KPIHelper.getTeachers(offset)

      # Save to database
      KPIHelper.saveTeachersFrom(json)

      offset += 100
    end
  end


  # Make request to API for get total count of all teachers
  def self.getTeachersCount
    # Init URI
    uri = URI("https://api.rozklad.org.ua/v2/teachers")
    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    totalCount = json["meta"]["total_count"]
    teachersTotalCount = Integer(totalCount)

    return teachersTotalCount
  end


  # Make request with offset parameter and parse JSON
  def self.getTeachers(offset)
     # Init URI
     uri = URI("https://api.rozklad.org.ua/v2/teachers/?filter={%27limit%27:100,%27offset%27:#{offset}}")
     if uri.nil?
      # Add error
      error_message = "Invalid URI"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

     # Perform request
     response = Net::HTTP.get_response(uri)
     if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      self.errors.add(:base, error_message)
      # Log invalid URI
      logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    return json
  end


  # Serialize teachers from JSON and save to database
  def self.saveTeachersFrom(json)

    data = json["data"]

    # This groups for SumDU
    university = University.find_by(url: "kpi")
    
    for object in data do

      begin

        # Convert before save
        serverID = Integer(object["teacher_id"])
        teacherName = String(object["teacher_name"])

        # Save new teacher
        teacher = Teacher.new
        teacher.server_id = serverID
        teacher.name = teacherName
        teacher.university = university

        unless teacher.save
          # Go to the next iteration if can't be saved
          logger.error(teacher.errors.full_messages)
          next
        end

      rescue Exception => e
        logger.error(e)
        next
      end

    end
  end

end