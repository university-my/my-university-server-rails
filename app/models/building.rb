class Building < ApplicationRecord

# Associations
belongs_to :university, optional: true
has_many :auditoriums

end
