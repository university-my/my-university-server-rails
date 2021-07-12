module ActiveAdmin
  class DisciplineNameSuggestionPolicy < ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      user
    end

    def show?
      true
    end

    def create?
      false
    end

    def new?
      create?
    end

    def update?
      true
    end

    def edit?
      update?
    end

    def destroy?
      true
    end
  end
end
