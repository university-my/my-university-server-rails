class DepartmentsController < ApplicationController

  # GET /departments
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 5
    @query = params["query"]
    if @query.present?
      @departments = Department.where(university: @university)
      .where("name LIKE ?", "%#{@query}%")
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    else
      @departments = Department.where(university: @university)
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /departments/1
  def show
    @university = University.find_by!(url: params[:university_url])
    @department = @university.departments.friendly.find(params[:id])
    per_page = 6
    @query = params["query"]
    if @query.present?
      @teachers = @department.teachers
      .where("lowercase_name LIKE ?", "%#{@query.downcase}%")
      .paginate(page: params[:page], per_page: per_page)
    else
      @teachers = @department.teachers
      .paginate(page: params[:page], per_page: per_page)
    end
  end
end
