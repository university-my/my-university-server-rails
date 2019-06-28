class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable
  
  # Constants
  ADMIN_ROLES = %w(admin reader kpi_editor sumdu_editor)
  
  # Fields validations
  validates :role, presence: true, inclusion: { in: AdminUser::ADMIN_ROLES }
  
  def is_admin?
    self.role == 'admin'
  end
  
  def is_reader?
    self.role == 'reader'
  end
  
  def is_kpi_editor?
    self.role == 'kpi_editor'
  end
  
  def is_sumdu_editor?
    self.role == 'sumdu_editor'
  end
end
