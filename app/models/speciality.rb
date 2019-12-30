class Speciality < ApplicationRecord

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

  # Associations
  belongs_to :university, optional: true
  has_many :groups

end
