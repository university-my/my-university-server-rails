class Record < ApplicationRecord

  # Associations
  belongs_to :auditorium, optional: true
  has_and_belongs_to_many :groups, optional: true
  belongs_to :teacher, optional: true

end
