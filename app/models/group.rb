require 'net/http'
require 'json'

class Group < ApplicationRecord

  # Fields validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: true

  # Associations
  has_and_belongs_to_many :records, optional: true, dependent: :nullify
  belongs_to :university, optional: true

  # bin/rails runner 'Group.resetUpdateDate'
  def self.resetUpdateDate
    Group.update_all(updated_at: DateTime.current - 2.hour)
  end


  # Import records for current Group
  def importRecords
    if university.url == "sumdu"
      SumduHelper.importRecordsForGroup(self)
    end

    if university.url == "kpi"
      KpiHelper.importRecordsForGroup(self)
    end
  end


  # Check if need to update records in the Group
  def needToUpdateRecords
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 1.hour)
      needToUpdate = true
    end

    return needToUpdate
  end

end
