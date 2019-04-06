class PagesController < ApplicationController

  def about
    @title = "Мій Університет - Про сервіс"
      render "pages/about"
  end

  def contacts
    @title = "Мій Університет - Контакти"
      render "pages/contacts"
  end

  def cooperation
    @title = "Мій Університет - Співпраця"
      render "pages/cooperation"
  end

  def privacy_policy
    @title = "My University - Privacy Policy"
      render "pages/privacy-policy"
  end

  def terms_of_service
    @title = "My University - Terms of Service"
      render "pages/terms-of-service"
  end
end
