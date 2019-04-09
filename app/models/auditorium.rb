require 'net/http'
require 'json'

class Auditorium < ApplicationRecord
  self.table_name = "auditoriums"

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_many :records, dependent: :nullify
  belongs_to :university, optional: true


  # bin/rails runner 'Auditorium.resetUpdateDate'
  def self.resetUpdateDate
    Auditorium.update_all(updated_at: DateTime.current - 2.hour)
  end


  # Import records for current Auditorium
  def importRecords
    SumDUHelper.importRecordsForAuditorium(self)
  end
  

  # Check if need to update records in the Auditorium
  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
  end
end
