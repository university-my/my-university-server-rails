class Api::V1::BuildingsController < ApplicationController

  # GET /api/v1/universities/:university_url/buildings
  def index
    university = University.find_by!(url: params[:university_url])
    @buildings = university.buildings
  end
end
