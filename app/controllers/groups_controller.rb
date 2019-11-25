class GroupsController < ApplicationController

  # GET /groups
  # GET /groups.json
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 6
    @query = params["query"]
    if @query.present?
      @groups = @university.groups
      .where("lowercase_name LIKE ?", "%#{@query.downcase}%")
      .paginate(page: params[:page], per_page: per_page)
    else
      @groups = @university.groups
        .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @group = @university.groups.friendly.find(params[:id])

    # Date
    @pair_date = pair_date_string_from(params)
    @date = @pair_date.to_date
    @nextDate = @date + 1.day
    @previousDate = @date - 1.day
  end

  # GET /groups/1/records
  # GET /groups/1/records.json
  def records
    @university = University.find_by!(url: params[:university_url])
    @group = Group.find_by!(university_id: @university.id, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    @records = Record.joins(:groups)
    .where(university: @university)
    .where('groups.id': @group.id)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)

    if @records.blank?
      @group.import_records(pair_date)

    elsif @group.need_to_update_records

      # Update
      @group.import_records(pair_date)
    end

    # Select records one more time
    @records = Record.joins(:groups)
    .where(university: @university)
    .where('groups.id': @group.id)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)

    @records_days = @records.group_by { |t| t.start_date }

    if @records.blank?
      render partial: "records/empty"
    else
      render partial: "records/show", locals: {
        records: @records,
        university: @university,
        pair_date: pair_date
      }
    end
  end
end
