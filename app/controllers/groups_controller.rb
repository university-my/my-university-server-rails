class GroupsController < ApplicationController

  # GET /groups
  # GET /groups.json
  def index
    @university = University.find_by!(url: params[:university_url])
    @groups = Group.where(university_id: @university.id).all
    @title = @university.short_name + ' - Групи'
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @group = @university.groups.friendly.find(params[:id])
    @title = @university.short_name + ' - ' + @group.name
  end
  
  # GET /groups/1/records
  # GET /groups/1/records.json
  def records
    @university = University.find_by!(url: params[:university_url])
    @group = Group.find_by!(university_id: @university.id, id: params[:id])
    
    # Check if need to update records
    if @group.need_to_update_records

      # Import new
      @group.import_records
    end
    
    current_day = DateTime.current.beginning_of_day
    @records = Record.joins(:groups).where(university_id: @university.id, 'groups.id': @group.id).where("start_date >= ?", current_day).order(:start_date).order(:pair_name)
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
      render :partial => "records/empty"
    else
      render :partial => "records/show", :locals => {:records => @records, :university => @university}
    end
  end
end
