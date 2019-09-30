class HomepageController < ApplicationController
  def home
    @title = "Мій Університет"
    @universities = University.where(is_hidden: false).limit(3)
  end
end
