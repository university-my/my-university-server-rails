class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable
  
  # Constants
  ADMIN_ROLES = %w(admin reader kpi_editor sumdu_editor)
  
  # Fields validations
  validates :role, presence: true, inclusion: { in: AdminUser::ADMIN_ROLES }
end
