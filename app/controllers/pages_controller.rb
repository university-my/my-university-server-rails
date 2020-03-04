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
    @title = "Мій Університет - Політика конфіденційності"
    render "pages/privacy-policy"
  end

  def privacy_policy_ios
    @title = "My University - iOS Privacy Policy"
    render "pages/privacy-policy-ios"
  end

  def terms_of_service
    @title = "Мій Університет - Умови обслуговування"
    render "pages/terms-of-service"
  end

  def zno2019
    @title = "Мій Університет - ЗНО 2019"
    render "pages/zno2019"
  end

  def ios
    render "pages/ios"
  end

  def android
    render "pages/android"
  end

  def telegram_channels
    render "pages/telegram-channels"
  end

  def patreon
    render "pages/patreon"
  end
end
