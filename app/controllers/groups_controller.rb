class GroupsController < ApplicationController
  before_action :set_group, only: [:show]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
    @university = University.find_by(url: params[:university_url])
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    # Check if need to update records
    if @group.needToUpdateRecords

      # Import new
      @group.importRecords

      redirect_to request.url
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
      @records = Record.joins(:groups).where('groups.id': @group.id).order(:start_date).order(:pair_name)
      @records_days = @records.group_by { |t| t.start_date }
      @university = University.find_by(url: params[:university_url])
    end
  end
