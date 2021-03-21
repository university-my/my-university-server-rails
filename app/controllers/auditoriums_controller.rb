class AuditoriumsController < ApplicationController

  # GET /auditoriums
  def index
    @university = University.find_by!(url: params[:university_url])
    @query = params['query']
    @auditoriums = if @query.present?
                     @university.auditorium
                                .where(is_hidden: false)
                                .where('lowercase_name LIKE ?', "%#{@query.downcase}%")
                                .paginate(page: params[:page], per_page: 6)
                   else
                     @university.auditorium
                                .where(is_hidden: false)
                                .paginate(page: params[:page], per_page: 6)
                   end
  end

  # GET /auditoriums/1
  def show
    @university = University.find_by!(url: params[:university_url])
    @auditorium = @university.auditorium.friendly.find(params[:id])

    # Date
    @pair_date = pair_date_string_from(params)
    @date = @pair_date.to_date
    @next_date = @date + 1.day
    @previous_date = @date - 1.day
  end

  # GET /auditoriums/1/records
  def records
    @university = University.find_by!(url: params[:university_url])
    @auditorium = Auditorium.find_by!(university_id: @university.id, id: params[:id])
    # Date
    pair_date = pair_date_from(params)
    @records = Record.where(university: @university)
                     .where(auditorium: @auditorium)
                     .where(pair_start_date: pair_date.all_day)
                     .order(:pair_start_date)
                     .order(:pair_name)

    if @records.blank?
      @auditorium.import_records(pair_date)
    elsif @auditorium.need_to_update_records
      @auditorium.import_records(pair_date)
    end

    # Select records one more time
    @records = Record.where(university: @university)
                     .where(auditorium: @auditorium)
                     .where(pair_start_date: pair_date.all_day)
                     .order(:pair_start_date)
                     .order(:pair_name)

    if @records.blank?

      # Try to find records on the next days
      next_records = Record.where(university: @university)
      .where(auditorium: @auditorium)
      .where("pair_start_date >= :date", date: pair_date.tomorrow.beginning_of_day)
      .order(:pair_start_date)
      .order(:pair_name)
      .limit(1)
      
      render partial: 'records/empty', locals: {
        next_records: next_records
      }
    else
      render partial: 'records/show', locals: {
        records: @records,
        university: @university,
        pair_date: pair_date
      }
    end
  end

end
