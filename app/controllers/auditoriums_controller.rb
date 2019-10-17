class AuditoriumsController < ApplicationController

  # GET /auditoriums
  # GET /auditoriums.json
  def index
    @university = University.find_by!(url: params[:university_url])
    @buildings = Building.where(university_id: @university.id).all
    @auditoriums = Auditorium.where(university_id: @university.id).all
    @title = @university.short_name + ' - Аудиторії'
  end

  # GET /auditoriums/1
  # GET /auditoriums/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @auditorium = @university.auditorium.friendly.find(params[:id])

    # Date
    @pair_date = pair_date_string_from(params)
    @date = @pair_date.to_date
    @nextDate = @date + 1.day
    @previousDate = @date - 1.day

    # Title
    @title = "#{@university.short_name} - #{@auditorium.name} (#{localized_string_from(@date)})"
  end

  # GET /auditoriums/1/records
  # GET /auditoriums/1/records.json
  def records
    @university = University.find_by!(url: params[:university_url])
    @auditorium = Auditorium.find_by!(university_id: @university.id, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    @records = Record.where(university_id: @university.id)
    .where(auditorium: @auditorium)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)

    if @records.empty?
      @auditorium.import_records(pair_date)

    elsif @auditorium.need_to_update_records

      # Update
      @auditorium.import_records(pair_date)
    end

    # Select records one more time
    @records = Record.where(university_id: @university.id)
    .where(auditorium: @auditorium)
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
