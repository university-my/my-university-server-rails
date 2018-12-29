class GroupsController < ApplicationController
  before_action :set_group, only: [:show]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    # Check if need to update records
    if @group.needToUpdateRecords

      # Delete old records
      @group.records.destroy_all

      # Import new
      @group.importRecords

      redirect_to request.url, notice: "Records has been updated!"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end
  end
