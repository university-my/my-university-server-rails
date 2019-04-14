class AuditoriumsController < ApplicationController

  # GET /auditoriums
  # GET /auditoriums.json
  def index
    @university = University.find_by(url: params[:university_url])
    if @university.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    @auditoriums = Auditorium.where(university_id: @university.id).all
    @title = @university.short_name + ' - Аудиторії'
  end

  # GET /auditoriums/1
  # GET /auditoriums/1.json
  def show
    @university = University.find_by(url: params[:university_url])
    if @university.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    @auditorium = Auditorium.find_by(university_id: @university.id, id: params[:id])
    if @auditorium.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    @title = @university.short_name + ' - ' + @auditorium.name
  end
  
  def records
    @university = University.find_by(url: params[:university_url])
    if @university.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    @auditorium = Auditorium.find_by(university_id: @university.id, id: params[:id])
    if @auditorium.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    # Check if need to update records
    if @auditorium.needToUpdateRecords

      # Import new
      @auditorium.importRecords
    end
    
    @records = Record.where(university_id: @university.id, auditorium: @auditorium).where("start_date >= ?", DateTime.current).order(:start_date).order(:pair_name)
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university => @university}
    end
  end
end
