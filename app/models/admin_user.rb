class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable

  # Constants
  ADMIN_ROLES = %w(admin reader editor)

  # Associations
  belongs_to :university, optional: true

  # Associations
  validates :university, presence: true, if: :is_editor?

  # Fields validations
  validates :role, presence: true, inclusion: { in: AdminUser::ADMIN_ROLES }

  def is_admin?
    self.role == 'admin'
  end

  def is_reader?
    self.role == 'reader'
  end

  def is_editor?
    self.role == 'editor'
  end
end
