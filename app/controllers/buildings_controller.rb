class BuildingsController < ApplicationController

  # GET /buildings
  # GET /buildings.json
  def index
    @university = University.find_by!(url: params[:university_url])
    @buildings = Building.where(university_id: @university.id).all
  end

  # GET /buildings/1
  # GET /buildings/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @building = @university.buildings.friendly.find(params[:id])
  end
end
