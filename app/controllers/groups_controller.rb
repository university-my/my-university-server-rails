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
    needToUpdate = false
    oneHour = (60 * 60)

    # TODO: Fix this checks
    # Check by date
    if Time.now.to_datetime >= (@group.updated_at + oneHour)
      needToUpdate = true
    end

    # Check by records
    if @group.records.length == 0
      needToUpdate = true
    end

    if needToUpdate
      # Delete old records
      @group.records.destroy_all

      # Import new
      @group.importRecords
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end
  end
