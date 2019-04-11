class UniversitiesController < ApplicationController
  before_action :set_university, only: [:show]

  # GET /universities
  # GET /universities.json
  def index
    @universities = University.all
    @title = 'Мій Університет - Університети'
  end

  # GET /universities/1
  # GET /universities/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_university
      @university = University.find_by(url: params[:url])
      @title = 'Мій Університет - ' + @university.short_name
    end
end
