require 'net/http'
require 'json'

class Teacher < ApplicationRecord

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { greater_than: 0 }, uniqueness: true

  # Associations
  has_many :records, dependent: :nullify
  belongs_to :university, optional: true


  # bin/rails runner 'Teacher.reset_update_date'
  def self.reset_update_date
    Teacher.update_all(updated_at: DateTime.current - 2.hour)
  end


  # Import records for teacher for SumDU
  def import_records
    if university.url == "sumdu"
      SumduHelper.import_records_for_teacher(self)
    end

    if university.url == "kpi"
      KpiHelper.import_records_for_teacher(self)
    end
  end
  

  # Check if need to update records in the Teacher
  def need_to_update_records
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
  end

end
