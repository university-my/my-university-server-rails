class TeachersController < ApplicationController

  # GET /teachers
  # GET /teachers.json
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 6
    @query = params["query"]
    if @query.present?
      @teachers = @university.teachers
        .where("lowercase_name LIKE ?", "%#{@query.downcase}%")
        .paginate(page: params[:page], per_page: per_page)
    else
      @teachers = @university.teachers
        .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @teacher = @university.teachers.friendly.find(params[:id])

    # Date
    @pair_date = pair_date_string_from(params)
    @date = @pair_date.to_date
    @nextDate = @date + 1.day
    @previousDate = @date - 1.day
  end

  # GET /teachers/1/records
  # GET /teachers/1/records.json
  def records
    @university = University.find_by!(url: params[:university_url])
    @teacher = Teacher.find_by!(university_id: @university.id, id: params[:id])

    # Date
    pair_date = pair_date_from(params)

    # TODO: Maybe use count

    @records = Record.where(university: @university)
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
    @records = Record.where(university: @university)
    .where(teacher_id: @teacher.id)
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
