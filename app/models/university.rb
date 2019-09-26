class University < ApplicationRecord
  # Associations
  has_many :auditorium
  has_many :admin_users
  has_many :groups
  has_many :teachers
  
  def self.sumdu_url
    "sumdu"
  end
  
  def self.kpi_url
    "kpi"
  end
  
  def self.khnue_url
    "khnue"
  end
  
  def self.sumdu
    University.find_by(url: University.sumdu_url)
  end
  
  def self.kpi
    University.find_by(url: University.kpi_url)
  end
  
  def self.khnue
    University.find_by(url: University.khnue_url)
  end
end
