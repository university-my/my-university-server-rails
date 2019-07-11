class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :member_not_authorized
  
  before_action :check_host

  def check_host
    if @_request.host == "djkmiles.com"
      redirect_to "https://www.google.com", :status => 301
    end
  end
  
  private
    def member_not_authorized
      flash[:alert] = 'You are not authorized to perform this action'
      redirect_back(fallback_location: admin_root_path)
    end
end
