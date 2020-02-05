class Discipline < ApplicationRecord

  # Associations
  belongs_to :university, optional: true
  has_and_belongs_to_many :auditoriums, optional: true
  has_and_belongs_to_many :groups, optional: true
  has_and_belongs_to_many :teachers, optional: true

  #
  # Import
  #
  def assign(new_auditorium, new_groups, new_teacher)
    # Push only unique auditoriums
    if new_auditorium.present?
      if !auditoriums.include?(new_auditorium)
        auditoriums << new_auditorium
      end
    end

    # Push only unique groups
    for group in new_groups do
      unless groups.include?(group)
        groups << group
      end
    end

    # Push only unique teachers
    if new_teacher.present?
      if !teachers.include?(new_teacher)
        teachers << new_teacher
      end
    end
  end

  def self.save_or_update(name, university, auditorium, groups, teacher)
    # Conditions for find existing discipline
    conditions = {}
    conditions[:university_id] = university.id
    conditions[:name] = name

    # Try to find existing discipline first
    discipline = Discipline.find_by(conditions)

    if discipline.nil?
      # Save new
      discipline = Discipline.new
      discipline.name = name
      discipline.university = university

      # Auditorium, Groups, Teacher
      discipline.assign(auditorium, groups, teacher)

      unless discipline.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(discipline.errors.full_messages)
      end
      return discipline
    else
      # Update

      # Auditorium, Groups, Teacher
      discipline.assign(auditorium, groups, teacher)

      unless discipline.save
        # Go to the next iteration if can't be saved
        Rails.logger.error(discipline.errors.full_messages)
      end
      return discipline
    end
  end

end
