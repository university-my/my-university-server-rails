module  RecordsHelper

  # Get pair date from params or use today date
  def pair_date_string_from(params)
    params[:pair_date] || Date.today.strftime('%F')
  end

  # Get pair date from params or use today date
  def pair_date_from(params)
    if params.key?(:pair_date)
      params[:pair_date].to_date
    else
      Date.today
    end
  end

  # Localized string from date
  def localized_string_from(date)
    l(date, format: '%A, %e %B')
  end

  def self.fetch_records(university, group, pair_date)
    Record.joins(:groups)
    .where(university: university)
    .where('groups.id': group.id)
    .where(pair_start_date: pair_date.all_day)
    .order(:pair_start_date)
    .order(:pair_name)
  end

  def self.next_records(university, group, pair_date)
    Record.joins(:groups)
    .where(university: university)
    .where('groups.id': group.id)
    .where("pair_start_date >= :date", date: pair_date.tomorrow.beginning_of_day)
    .order(:pair_start_date)
    .order(:pair_name)
    .limit(1)
  end

end
