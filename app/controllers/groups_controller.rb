class GroupsController < ApplicationController
  before_action :set_group, only: [:show]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
    @university = University.find_by(url: params[:university_url])
    @title = @university.short_name + ' - Групи'
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end
  
  def records
    @group = Group.find(params[:id])
    @university = University.find_by(url: params[:university_url])
    # Check if need to update records
    if @group.needToUpdateRecords

      # Import new
      @group.importRecords
    end
    
    @records = Record.joins(:groups).where('groups.id': @group.id).where("start_date >= ?", DateTime.current).order(:start_date).order(:pair_name)
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university =>  @university}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
      @university = University.find_by(url: params[:university_url])
      @title = @university.short_name + ' - ' + @group.name
    end
  end
