class Api::V1::GroupsController < ApplicationController

  # GET /api/v1/universities/:university_url/groups
  def index
    university = University.find_by!(url: params[:university_url])
    @groups = university.groups.where(is_hidden: false)
  end

  # GET /api/v1/universities/:university_url/groups/:id/records
  def records
    university = University.find_by!(url: params[:university_url])
    @group = Group.find_by!(university: university, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    @records = fetch_records(university, @group, pair_date)

    if @records.blank?
      @group.import_records(pair_date)

    elsif @group.need_to_update_records

      # Update
      @group.import_records(pair_date)
    end

    # Select records one more time
    @records = fetch_records(university, @group, pair_date)
  end

  def fetch_records(university, group, pair_date)
    Record.joins(:groups)
          .where(university: university)
          .where('groups.id': group.id)
          .where(pair_start_date: pair_date.all_day)
          .order(:pair_start_date)
          .order(:pair_name)
  end

end
