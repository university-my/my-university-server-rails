class University < ApplicationRecord
  # Associations
  has_many :auditorium
  has_many :admin_users
  has_many :groups
  has_many :teachers
end
