class Discipline < ApplicationRecord

  # Associations
  belongs_to :university, optional: true
  has_and_belongs_to_many :auditoriums, optional: true
  has_and_belongs_to_many :groups, optional: true
  has_and_belongs_to_many :teachers, optional: true

end
