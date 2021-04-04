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
  has_many :disciplines

  def self.all_universities
   [
    { uid: 1, service: 'SumduService' },
    { uid: 2, service: 'KpiService' },
    { uid: 3, service: 'KhnueService'},
    { uid: 4, service: 'NauService'},
    { uid: 5, service: 'PnuService'},
    { uid: 6, service: 'ZnauService'},
    { uid: 7, service: 'NuftService'},
    { uid: 8, service: 'SspuService'},
    { uid: 9, service: 'GpnuService'},
    { uid: 10, service: 'LnuService'},
    { uid: 11, service: 'NuwmService'},
    { uid: 12, service: 'UbsService'},
    { uid: 13, service: 'LdubgdService'},
    { uid: 14, service: 'NungService'},
    { uid: 16, service: 'NpuService'},
    { uid: 17, service: 'KtepcKnuteService'},
    { uid: 18, service: 'UgiService'}
  ]
end

  def self.service_for(uid)
    object = University.all_universities.select { |hash| hash[:uid] == uid }.first
    return if object.nil?
    return object[:service]
  end

  def self.short_names_array
    University.where(is_hidden: false).flat_map { |object|  object.short_name }
  end

  # Universities

  def self.sumdu
    University.find_by(uid: 1)
  end

  def self.kpi
    University.find_by(uid: 2)
  end

  def self.khnue
    University.find_by(uid: 3)
  end

  def self.nau
    University.find_by(uid: 4)
  end

  def self.pnu
    University.find_by(uid: 5)
  end

  def self.znau
    University.find_by(uid: 6)
  end

  def self.nuft
    University.find_by(uid: 7)
  end

  def self.sspu
    University.find_by(uid: 8)
  end

  def self.gpnu
    University.find_by(uid: 9)
  end

  def self.lnu
    University.find_by(uid: 10)
  end

  def self.nuwm
    University.find_by(uid: 11)
  end

  def self.ubs
    University.find_by(uid: 12)
  end

  def self.ldubgd
    University.find_by(uid: 13)
  end

  def self.nung
    University.find_by(uid: 14)
  end

  def self.npu
    University.find_by(uid: 16)
  end

  def self.ktepc_knute
    University.find_by(uid: 17)
  end

  def self.ugi
    University.find_by(uid: 18)
  end

end
