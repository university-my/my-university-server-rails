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

    # Date
    @pair_date = pair_date_string_from(params)
    date = @pair_date.to_date

    # Title
    @title = "#{@university.short_name} - #{@group.name} (#{localized_string_from(date)})"
  end
  
  # GET /groups/1/records
  # GET /groups/1/records.json
  def records
    @university = University.find_by!(url: params[:university_url])
    @group = Group.find_by!(university_id: @university.id, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    @records = Record.where(university_id: @university.id)
    .where(auditorium: @auditorium)
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
    
    @records_days = @records.group_by { |t| t.start_date }
    
    if @records.empty?
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
