module ActiveAdmin
  class TeacherPolicy < ApplicationPolicy
    attr_reader :user, :record
    
    def initialize(user, record)
      @user = user
      @record = record
    end
    
    def index?
      user
    end
    
    def show?
      user.is_admin?
    end
    
    def create?
      user.is_admin?
    end
    
    def new?
      create?
    end
    
    def update?
      user.is_admin?
    end
    
    def edit?
      update?
    end
    
    def destroy?
      user.is_admin?
    end
  end
end
