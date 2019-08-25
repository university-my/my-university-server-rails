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

    # Date
    @pair_date = pair_date_string_from_params
    date = @pair_date.to_date

    # Title
    @title = @university.short_name + ' - ' + @teacher.name + " (#{localized_string_from(date)})"
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

    # Date
    pair_date = pair_date_from_params

    @records = Record.where(university_id: @university.id)
      .where(teacher_id: @teacher.id)
      .where(pair_start_date: pair_date.all_day)
      .order(:pair_start_date)
      .order(:pair_name)
    
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {
        :records => @records,
        :university => @university,
        :pair_date => pair_date
      }
    end
  end
end