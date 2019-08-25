class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :member_not_authorized
  
  before_action :check_host

  def check_host
    if @_request.host == "djkmiles.com"
      redirect_to "https://www.google.com", :status => 301
    end
  end

  # Get pair date from params or use today date
  def pair_date_string_from_params
    # pair_date as String
    if params.has_key?(:pair_date)
      pair_date = params[:pair_date]
    else
      pair_date = Date.today.strftime("%F")
    end

    return pair_date
  end

  # Get pair date from params or use today date
  def pair_date_from_params
    if params.has_key?(:pair_date)
      pair_date = params[:pair_date].to_date
    else
      pair_date = Date.today
    end

    return pair_date
  end

  # Localized string from date
  def localized_string_from(date)
    return l(date, format: '%A, %e %B')
  end
  
  private
    def member_not_authorized
      flash[:alert] = 'You are not authorized to perform this action'
      redirect_back(fallback_location: admin_root_path)
    end
end
