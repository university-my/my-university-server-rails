class DisciplinesController < ApplicationController

  # GET /universities/:university_url/disciplines
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 5
    @query = params["query"]
    if @query.present?
      @disciplines = Discipline.where(university: @university)
      .where("visible_name LIKE ?", "%#{@query.downcase}%")
      .order(:visible_name)
      .paginate(page: params[:page], per_page: per_page)
    else
      @disciplines = Discipline.where(university: @university)
      .order(:visible_name)
      .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /universities/:university_url/disciplines/:friendly_id
  def show
    @university = University.find_by!(url: params[:university_url])
    @discipline = @university.disciplines.friendly.find(params[:id])
  end

end