class TeachersController < ApplicationController

  # GET /teachers
  # GET /teachers.json
  def index
    @university = University.find_by!(url: params[:university_url])
    per_page = 6
    @query = params["query"]
    if @query.present?
      @teachers = @university.teachers
        .where(is_hidden: false)
        .where("lowercase_name LIKE ?", "%#{@query.downcase}%")
        .paginate(page: params[:page], per_page: per_page)
    else
      @teachers = @university.teachers
        .where(is_hidden: false)
        .paginate(page: params[:page], per_page: per_page)
    end
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
    @university = University.find_by!(url: params[:university_url])
    @teacher = @university.teachers
    .where(is_hidden: false)
    .friendly
    .find(params[:id])

    # Date
    @pair_date = pair_date_string_from(params)
    @date = @pair_date.to_date
    @next_date = @date + 1.day
    @previous_date = @date - 1.day
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

    if @records.blank?

      # Try to find records on the next days
      next_records = Record.where(university: @university)
      .where(teacher_id: @teacher.id)
      .where("pair_start_date >= :date", date: pair_date.tomorrow.beginning_of_day)
      .order(:pair_start_date)
      .order(:pair_name)
      .limit(1)

      render partial: "records/empty", locals: {
        next_records: next_records
      }
    else
      render partial: "records/show", locals: {
        records: @records,
        university: @university,
        pair_date: pair_date
      }
    end
  end
end
