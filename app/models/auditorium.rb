require 'net/http'
require 'json'

class Auditorium < ApplicationRecord
  self.table_name = "auditoriums"

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

  before_validation :add_lowercase_name

  def add_lowercase_name
    self.lowercase_name = name.downcase
  end

  # Field validations
  validates :name, presence: true
  validates :server_id, presence: true, numericality: { other_than: 0 }, uniqueness: false

  # Associations
  has_and_belongs_to_many :disciplines, optional: true
  has_many :records, dependent: :nullify
  belongs_to :university, optional: true
  belongs_to :building, optional: true

  # bin/rails runner 'Auditorium.reset_update_date'
  def self.reset_update_date
    Auditorium.update_all(updated_at: DateTime.current - 21.hour)
  end


  # Import records for current Auditorium
  def import_records(date)
    case university.url

    when University.sumdu_url
      SumduService.import_records_for_auditorium(self, date)

    # when University.khnue_url
    #   KhnueService.import_records_for_auditorium(self, date)
    end
  end


  # Check if need to update records in the Auditorium
  def need_to_update_records
    needToUpdate = false

    # Check by date
    if DateTime.current >= (updated_at + 20.hour)
      needToUpdate = true
    end

    return needToUpdate
  end
end
