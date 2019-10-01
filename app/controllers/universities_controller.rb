class UniversitiesController < ApplicationController

  # GET /universities
  # GET /universities.json
  def index
    @universities = University.where(is_hidden: false)
    @title = 'Мій Університет - Всі університети'
  end

  # GET /universities/1
  # GET /universities/1.json
  def show
    @university = University.find_by!(url: params[:url])
  end
end
