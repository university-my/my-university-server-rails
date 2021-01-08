class University < ApplicationRecord
  # Associations
  has_many :auditorium
  has_many :admin_users
  has_many :groups
  has_many :teachers
  has_many :buildings
  has_many :departments
  has_many :faculties
  has_many :specialities

  # SumDU

  def self.sumdu_url
    "sumdu"
  end

  def self.sumdu
    University.find_by(url: University.sumdu_url)
  end

  # KPI

  def self.kpi_url
    "kpi"
  end

  def self.kpi
    University.find_by(url: University.kpi_url)
  end

  # KHNUE

  def self.khnue_url
    "khnue"
  end

  def self.khnue
    University.find_by(url: University.khnue_url)
  end

  # NAU

  def self.nau_url
    return "nau"
  end

  def self.nau
    University.find_by(url: University.nau_url)
  end

  # PNU

  def self.pnu_url
    return "pnu"
  end

  def self.pnu
    University.find_by(url: University.pnu_url)
  end

end
