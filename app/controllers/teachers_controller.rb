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
    @teacher = @university.teachers.friendly.find(params[:id])
    @title = @university.short_name + ' - ' + @teacher.name
    if params.has_key?(:pair_date)
      @pair_date = params[:pair_date]
    else
      @pair_date = Date.today
    end
  end

  # GET /teachers/1/records
  # GET /teachers/1/records.json
  def records
    @university = University.find_by!(url: params[:university_url])
    @teacher = Teacher.find_by!(university_id: @university.id, id: params[:id])
    
    # Check if need to update records
    if @teacher.need_to_update_records

      # Import new
      @teacher.import_records
    end

    if params.has_key?(:pair_date)
      # Records for date
      pair_date = params[:pair_date].to_date
    else
      # Records for current day
      pair_date = Date.today
    end

    @records = Record.where(university_id: @university.id)
      .where(teacher_id: @teacher.id)
      .where(pair_start_date: pair_date.all_day)
      .order(:pair_start_date)
      .order(:pair_name)
    
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university => @university}
    end
  end
end