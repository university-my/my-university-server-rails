class UniversitiesController < ApplicationController

  # GET /universities
  # GET /universities.json
  def index
    @short_names = University.short_names_array.join(',')

    per_page = 3
    @query = params["query"]
    if @query.present?
      @universities = University.where(is_hidden: false)
        .where("short_name LIKE ?", "%#{@query}%")
        .paginate(page: params[:page], per_page: per_page)
    else
      @universities = University.where(is_hidden: false)
        .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /universities/1
  # GET /universities/1.json
  def show
    @university = University.find_by!(url: params[:url])
  end
end
