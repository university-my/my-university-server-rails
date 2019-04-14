class GroupsController < ApplicationController

  # GET /groups
  # GET /groups.json
  def index
    @university = University.find_by(url: params[:university_url])
    if @university.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    @groups = Group.where(university_id: @university.id).all
    @title = @university.short_name + ' - Групи'
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @university = University.find_by(url: params[:university_url])
    if @university.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    @group = Group.find_by(university_id: @university.id, id: params[:id])
    if @group.blank?
      raise ActionController::RoutingError.new('Not Found')
    end

    @title = @university.short_name + ' - ' + @group.name
  end
  
  # GET /groups/1/records
  def records
    @university = University.find_by(url: params[:university_url])
    if @university.blank?
      raise ActionController::RoutingError.new('Not Found')  
    end

    @group = Group.find_by(university_id: @university.id, id: params[:id])
    if @group.blank?
      raise ActionController::RoutingError.new('Not Found')
    end
    
    # Check if need to update records
    if @group.needToUpdateRecords

      # Import new
      @group.importRecords
    end
    
    @records = Record.joins(:groups).where(university_id: @university.id, 'groups.id': @group.id).where("start_date >= ?", DateTime.current).order(:start_date).order(:pair_name)
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university =>  @university}
    end
  end
end
