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
      regular_permissions || user.is_reader?
    end
    
    def create?
      regular_permissions
    end
    
    def new?
      create?
    end
    
    def update?
      regular_permissions
    end
    
    def edit?
      update?
    end
    
    def destroy?
      regular_permissions
    end
  end
end
