class AuditoriumsController < ApplicationController
  before_action :set_auditorium, only: [:show]

  # GET /auditoriums
  # GET /auditoriums.json
  def index
    @auditoriums = Auditorium.all
    @university = University.find_by(url: params[:university_url])
    @title = @university.short_name + ' - Аудиторії'
  end

  # GET /auditoriums/1
  # GET /auditoriums/1.json
  def show
    # Check if need to update records
    if @auditorium.needToUpdateRecords

      # Import new
      @auditorium.importRecords

      redirect_to request.url
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_auditorium
      @auditorium = Auditorium.find(params[:id])
      @records = Record.where(auditorium: @auditorium).order(:start_date).order(:pair_name)
      @records_days = @records.group_by { |t| t.start_date }
      @university = University.find_by(url: params[:university_url])
      @title = @university.short_name + ' - ' + @auditorium.name
    end
end
