class BuildingsController < ApplicationController

  # GET /buildings
  # GET /buildings.json
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 5
    @query = params["query"]
    if @query.present?
      @buildings = Building.where(university: @university)
      .where("name LIKE ?", "%#{@query}%")
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    else
      @buildings = Building.where(university: @university)
      .order(:name)
      .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /buildings/1
  # GET /buildings/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @building = @university.buildings.friendly.find(params[:id])
    per_page = 6
    @query = params["query"]
    if @query.present?
      @auditoriums = @building.auditoriums
      .where("lowercase_name LIKE ?", "%#{@query.downcase}%")
      .paginate(page: params[:page], per_page: per_page)
    else
      @auditoriums = @building.auditoriums
      .paginate(page: params[:page], per_page: per_page)
    end
  end
end
