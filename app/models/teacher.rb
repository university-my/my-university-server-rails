require 'net/http'
require 'json'

class Teacher < ApplicationRecord

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { greater_than: 0 }, uniqueness: true

  # Associations
  has_many :records, dependent: :nullify
  belongs_to :university, optional: true


  # bin/rails runner 'Teacher.resetUpdateDate'
  def self.resetUpdateDate
    Teacher.update_all(updated_at: DateTime.current - 2.hour)
  end


  # Import records for teacher for SumDU
  def importRecords
    SumDUHelper.importRecordsForTeacher(self)
  end
  

  # Check if need to update records in the Teacher
  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
  end

end
