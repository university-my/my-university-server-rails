require 'net/http'
require 'json'
require "uri"

class PnuService

  def self.timetable_url
    'http://asu.pnu.edu.ua/cgi-bin/timetable.cgi'
  end

  def self.server_id
    101
  end

  def self.university
    University.pnu
  end
  

  # bin/rails runner 'PnuService.import_groups'
  def self.import_groups
    groups = PolitekService.load_objects('groups', self.timetable_url)

    PolitekService.save_groups(groups, self.university, self.server_id)
  end


  #
  # Import teachers
  #
  # bin/rails runner 'PnuService.import_teachers'
  def self.import_teachers
    teachers = PolitekService.load_objects('teachers', self.timetable_url)

    PolitekService.save_teachers(teachers, self.university, self.server_id)
  end


  def self.import_records_for_teacher(teacher, date)
    data = PolitekService.load_records_for('teachers', date, teacher.name, self.timetable_url)

    PolitekService.save_records_for_teacher(data, teacher, self.university)
  end


  def self.import_records_for_group(group, date)
    data = PolitekService.load_records_for('groups', date, group.name, self.timetable_url)

    PolitekService.save_records_for_group(data, group, self.university)
  end

end