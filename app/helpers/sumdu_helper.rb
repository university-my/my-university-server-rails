module SumDUHelper

  #
  # Import auditorums from SumDU API
  #

  # # bin/rails runner 'SumDUHelper.importAuditoriums'
  def self.importAuditoriums

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getAuditoriums")
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
          logger.error(auditorium.errors.full_messages)
          next
        end
        
      rescue Exception => e
        logger.error(e)
        next
      end
    end
  end

  #
  # Import groups from SumDU API
  #

  # bin/rails runner 'SumDUHelper.importGroups'
  def self.importGroups

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getGroups")
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
  # Import teachers from SumDU API
  #

  # Import from SumDU
  # bin/rails runner 'SumDUHelper.importTeachers'
  def self.importTeachers

    # Init URI
    uri = URI("http://schedule.sumdu.edu.ua/index/json?method=getTeachers")
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