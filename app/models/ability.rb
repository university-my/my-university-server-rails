class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    
    if user.role == 'admin'
      can :manage, :all
    elsif user.role == 'sumdu_editor'
      can :read, Auditorium, university_id: 1
      can :manage, Group, university_id: 1
      can :manage, Record, university_id: 1
      can :manage, Teacher, university_id: 1
    elsif user.role == 'kpi_editor'
      can :read, Auditorium, university_id: 2
      can :manage, Group, university_id: 2
      can :manage, Record, university_id: 2
      can :manage, Teacher, university_id: 2
    elsif user.role == 'reader'
      can :read, :all
    end
  end
end
