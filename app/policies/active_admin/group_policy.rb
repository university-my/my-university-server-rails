module ActiveAdmin
  class GroupPolicy < ApplicationPolicy
    attr_reader :user, :record
    
    def initialize(user, record)
      @user = user
      @record = record
    end
    
    def index?
      user
    end
    
    def show?
      user
    end
    
    def create?
      user.is_admin? || user.is_kpi_editor?
    end
    
    def new?
      create?
    end
    
    def update?
      user.is_admin? || user.is_kpi_editor?
    end
    
    def edit?
      update?
    end
    
    def destroy?
      user.is_admin?
    end
  end
end
