class TeachersController < ApplicationController

  # GET /teachers
  # GET /teachers.json
  def index
    @university = University.find_by!(url: params[:university_url])
    @teachers = Teacher.where(university_id: @university.id).all
    @title = @university.short_name + ' - Викладачі'
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @teacher = Teacher.find_by!(university_id: @university.id, id: params[:id])
    @title = @university.short_name + ' - ' + @teacher.name
  end

  # GET /teachers/1/records
  def records
    @university = University.find_by!(url: params[:university_url])
    @teacher = Teacher.find_by!(university_id: @university.id, id: params[:id])
    
    # Check if need to update records
    if @teacher.need_to_update_records
      # Import new
      @teacher.import_records
    end
    
    current_day = DateTime.current.beginning_of_day
    @records = Record.where(university_id: @university.id, teacher_id: @teacher.id).where("start_date >= ?", current_day).order(:start_date).order(:pair_name)
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university =>  @university}
    end
  end
end