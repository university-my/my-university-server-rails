class Record < ApplicationRecord

  # Associations
  belongs_to :auditorium, optional: true
  belongs_to :group, optional: true
  belongs_to :teacher, optional: true

end
