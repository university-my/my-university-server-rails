class Api::V1::AuditoriumsController < ApplicationController

  # GET /api/v1/universities/:university_url/auditoriums
  def index
    university = University.find_by!(url: params[:university_url])
    @auditoriums = university.auditorium.where(is_hidden: false)
  end

  # GET /api/v1/universities/:university_url/auditoriums/:id/records
  def records
    university = University.find_by!(url: params[:university_url])
    @auditorium = Auditorium.find_by!(university_id: university.id, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    @records = fetch_records(university, @auditorium, pair_date)

    if @records.blank?
      @auditorium.import_records(pair_date)
    elsif @auditorium.need_to_update_records
      @auditorium.import_records(pair_date)
    end

    # Select records one more time
    @records = fetch_records(university, @auditorium, pair_date)
  end

  def fetch_records(university, auditorium, pair_date)
    Record.where(university: university)
          .where(auditorium: auditorium)
          .where(pair_start_date: pair_date.all_day)
          .order(:pair_start_date)
          .order(:pair_name)
  end

end
