class SpecialitiesController < ApplicationController

  # GET /specialities
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 5
    @query = params["query"]
    if @query.present?
      @specialities = Speciality.where(university: @university)
      .where("name LIKE ?", "%#{@query}%")
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    else
      @specialities = Speciality.where(university: @university)
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /specialities/1
  def show
    @university = University.find_by!(url: params[:university_url])
    @speciality = @university.specialities.friendly.find(params[:id])
    per_page = 6
    @query = params["query"]
    if @query.present?
      @groups = @speciality.groups
      .where("lowercase_name LIKE ?", "%#{@query.downcase}%")
      .paginate(page: params[:page], per_page: per_page)
    else
      @groups = @speciality.groups
      .paginate(page: params[:page], per_page: per_page)
    end
  end
end
