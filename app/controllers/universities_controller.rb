class UniversitiesController < ApplicationController

  # GET /universities
  # GET /universities.json
  def index
    @universities = University.all
    @title = 'Мій Університет - Всі університети'
  end

  # GET /universities/1
  # GET /universities/1.json
  def show
    @university = University.find_by!(url: params[:url])
    @title = 'Мій Університет - ' + @university.short_name
  end
end
