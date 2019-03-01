class TeachersController < ApplicationController
  before_action :set_teacher, only: [:show]

  # GET /teachers
  # GET /teachers.json
  def index
    @teachers = Teacher.all
    @university = University.find_by(url: params[:university_url])
    @title = @university.short_name + ' - Викладачі'
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
  end
  
  def records
    @teacher = Teacher.find(params[:id])
    @university = University.find_by(url: params[:university_url])
    # Check if need to update records
    if @teacher.needToUpdateRecords

      # Import new
      @teacher.importRecords
    end
    
    @records = Record.where(teacher: @teacher).where("start_date >= ?", DateTime.current).order(:start_date).order(:pair_name)
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university =>  @university}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teacher
      @teacher = Teacher.find(params[:id])
      @university = University.find_by(url: params[:university_url])
      @title = @university.short_name + ' - ' + @teacher.name
    end
  end
