class Api::V1::TeachersController < ApplicationController

  # GET /api/v1/universities/:university_url/teachers
  def index
    university = University.find_by!(url: params[:university_url])
    @teachers = university.teachers
  end

  # GET /api/v1/universities/:university_url/teachers/:id/records
  def records
    university = University.find_by!(url: params[:university_url])
    @teacher = Teacher.find_by!(university: university, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    @records = Record.where(university: university)
    .where(teacher_id: @teacher.id)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)

    if @records.blank?
      @teacher.import_records(pair_date)

    elsif @teacher.need_to_update_records

      # Update
      @teacher.import_records(pair_date)
    end

    # Select records one more time
    @records = Record.where(university: university)
    .where(teacher_id: @teacher.id)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)
  end

end
