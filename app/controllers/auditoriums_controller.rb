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
  end
  
  def records
    @auditorium = Auditorium.find(params[:id])
    @university = University.find_by(url: params[:university_url])
    # Check if need to update records
    if @auditorium.needToUpdateRecords

      # Import new
      @auditorium.importRecords
    end
    
    @records = Record.where(auditorium: @auditorium).where("start_date >= ?", DateTime.current).order(:start_date).order(:pair_name)
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university =>  @university}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_auditorium
      @auditorium = Auditorium.find(params[:id])
      @university = University.find_by(url: params[:university_url])
      @title = @university.short_name + ' - ' + @auditorium.name
    end
end
