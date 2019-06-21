class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new

    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'sumdu_editor'
      can :read, Auditorium
      can :read, Group
      can [:read, :create, :update, :destroy], Record
      can :read, Teacher
      can [:read, :create, :update, :destroy], University
    elsif user.role == 'kpi_editor'
      can :read, Auditorium
      can :read, Group
      can [:read, :create, :update, :destroy], Record
      can :read, Teacher
      can [:read, :create, :update, :destroy], University
    elsif user.role == 'reader'
      can :read, :all
    end
  end
end
