class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end
  
  def regular_permissions
    if record.university.nil?
      user.is_admin? || user.is_kpi_editor? || user.is_sumdu_editor?
    else
      user.is_admin? || user.is_kpi_editor? && record.university == user.university || user.is_sumdu_editor? && record.university == user.university
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.is_admin? || user.is_reader?
        scope.all.order(id: :desc)
      elsif user.is_sumdu_editor? || user.is_kpi_editor?
        scope.where(university: user.university).order(id: :desc)
      end
    end
  end
end
