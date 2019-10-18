class Api::V1::UniversitiesController < ApplicationController

  # GET /api/v1/universities
  def index
    @universities = University.where(is_hidden: false)
  end
end
