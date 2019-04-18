class ApplicationController < ActionController::Base

  before_action :check_host

  def check_host
    if @_request.host == "djkmiles.com"
      redirect_to "https://www.google.com", :status => 301
    end
  end
end
