class TeachersController < ApplicationController
  before_action :set_teacher, only: [:show]

  # GET /teachers
  # GET /teachers.json
  def index
    @teachers = Teacher.all
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
    # Check if need to update records
    if @teacher.needToUpdateRecords

      # Delete old records
      @teacher.records.destroy_all

      # Import new
      @teacher.importRecords

      redirect_to request.url, notice: "Records has been updated!"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teacher
      @teacher = Teacher.find(params[:id])
      @records = Record.where(teacher: @teacher).order(:start_date).order(:pair_name)
      @records_days = @records.group_by { |t| t.start_date }
      @university = University.find_by(url: params[:university_url])
    end
  end
