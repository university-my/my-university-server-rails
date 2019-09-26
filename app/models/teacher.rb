require 'net/http'
require 'json'

class Teacher < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, :use => [:slugged, :simple_i18n]

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { greater_than: 0 }, uniqueness: false

  # Associations
  has_many :records, dependent: :nullify
  belongs_to :university, optional: true


  # bin/rails runner 'Teacher.reset_update_date'
  def self.reset_update_date
    Teacher.update_all(updated_at: DateTime.current - 21.hour)
  end


  # Import records for teacher for SumDU
  def import_records(date)
    case university.url
      
    when University.sumdu_url
      SumduService.import_records_for_teacher(self, date)
      
    when University.kpi_url
      KpiHelper.import_records_for_teacher(self)
      
    when University.khnue_url
      KhnueService.import_records_for_teacher(self, date)
    end
  end
  

  # Check if need to update records in the Teacher
  def need_to_update_records
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 20.hour)
      needToUpdate = true
    end

    return needToUpdate
  end

end
