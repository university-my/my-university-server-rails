require 'net/http'
require 'json'

class SumduService

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

    university = University.find_by(url: "sumdu")

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
        groups = Group.where(university_id: university.id, name: striped_names)

        # Auditorium
        # Convert to int before find request
        auditorium_id = kod_aud.to_i
        auditorium = Auditorium.where(university_id: university.id, server_id: auditorium_id).first

        # Pair start date
        start_date = date_string.to_datetime

        # Get pair date and time
        pair_time = time.split('-').first
        pair_start_date  = (date_string + ' ' + pair_time).to_datetime

        # Conditions for find existing pair
        conditions = {}
        conditions[:university_id] = university.id
        conditions[:start_date] = start_date
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
          record.start_date = start_date
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

          unless record.save
            # Go to the next iteration if record can't be saved
            Rails.logger.error(record.errors.full_messages)
            next
          end

        else
          record.start_date = start_date
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

end