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
      department_id = object['CODE'].to_i
      name = object['NAME']

      # Save department
      save_department(department_id, name)

      # Import groups for department
      import_groups(department_id)
    end
  end

  def self.save_department(id, name)
    department = Department.where(server_id: id, name: name).first
    university = University.nau

    if department.nil?
      # Save new department
      department = Department.new
      department.server_id = id
      department.name = name
      department.university = university

      unless department.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(department.errors.full_messages)
      end
    end
  end

  #
  # Group
  #
  def self.import_groups(department_id)
    url = "#{baseURL}/groups/#{department_id}"
    json = ApplicationRecord.perform_request(url)

    if json.nil?
      return
    end

    objects = json['groups']
    for object in objects do
      # TODO: Save groups
    end

  end

end
