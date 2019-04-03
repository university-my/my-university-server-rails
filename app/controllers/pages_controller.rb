class PagesController < ApplicationController

  def privacy_policy
    @title = "My University - Pricavy Policy"
      render "pages/privacy-policy"
  end

  def terms_of_service
    @title = "My University - Terms of Service"
      render "pages/terms-of-service"
  end
end
