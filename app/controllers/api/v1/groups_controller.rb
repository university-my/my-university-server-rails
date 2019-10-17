class Api::V1::GroupsController < ApplicationController

  # GET /api/v1/universities/:university_url/groups
  def index
    @university = University.find_by!(url: params[:university_url])
    @groups = Group.where(university_id: @university.id).all
  end

  # GET /api/v1/universities/:university_url/groups/:id/records
  def records
    @university = University.find_by!(url: params[:university_url])
    @group = Group.find_by!(university_id: @university.id, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    @records = Record.joins(:groups)
    .where(university_id: @university.id)
    .where('groups.id': @group.id)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)

    if @records.empty?
      @group.import_records(pair_date)

    elsif @group.need_to_update_records

      # Update
      @group.import_records(pair_date)
    end

    # Select records one more time
    @records = Record.joins(:groups)
    .where(university_id: @university.id)
    .where('groups.id': @group.id)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)
  end

end
