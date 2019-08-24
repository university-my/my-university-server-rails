class AuditoriumsController < ApplicationController

  # GET /auditoriums
  # GET /auditoriums.json
  def index
    @university = University.find_by!(url: params[:university_url])
    @auditoriums = Auditorium.where(university_id: @university.id).all
    @title = @university.short_name + ' - Аудиторії'
  end

  # GET /auditoriums/1
  # GET /auditoriums/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @auditorium = @university.auditorium.friendly.find(params[:id])
    @title = @university.short_name + ' - ' + @auditorium.name
    @pair_date = params[:pair_date]
  end
  
  # GET /auditoriums/1/records
  # GET /auditoriums/1/records.json
  def records
    @university = University.find_by!(url: params[:university_url])
    @auditorium = Auditorium.find_by!(university_id: @university.id, id: params[:id])

    # Check if need to update records
    if @auditorium.need_to_update_records

      # Import new
      @auditorium.import_records
    end

    if params.has_key?(:pair_date)
      # Records for date
      pair_date = params[:pair_date].to_date
      @records = Record.where(university_id: @university.id, auditorium: @auditorium)
      .where("pair_start_date == ?", pair_date)
      .order(:start_date)
      .order(:pair_name)
    else
      # Records for current day
      current_day = DateTime.current.beginning_of_day
      @records = Record.where(university_id: @university.id, auditorium: @auditorium)
      .where("pair_start_date == ?", current_day)
      .order(:start_date)
      .order(:pair_name)
    end
    
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university => @university}
    end
  end
end
