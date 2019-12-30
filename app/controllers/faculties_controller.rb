class FacultiesController < ApplicationController

  # GET /faculties
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 5
    @query = params["query"]
    if @query.present?
      @faculties = Faculty.where(university: @university)
      .where("name LIKE ?", "%#{@query}%")
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    else
      @faculties = Faculty.where(university: @university)
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /faculties/1
  def show
    @university = University.find_by!(url: params[:university_url])
    @faculty = @university.faculties.friendly.find(params[:id])
    per_page = 6
    @query = params["query"]
    if @query.present?
      @groups = @faculty.groups
      .where("lowercase_name LIKE ?", "%#{@query.downcase}%")
      .paginate(page: params[:page], per_page: per_page)
    else
      @groups = @faculty.groups
      .paginate(page: params[:page], per_page: per_page)
    end
  end
end
