class DisciplinesController < ApplicationController

  # GET /universities/:university_url/disciplines
  def index
    @university = University.find_by!(url: params[:university_url])
    @disciplines =  @university.disciplines
  end

end