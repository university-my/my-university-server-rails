class HomepageController < ApplicationController
  def home
    @universities = University.where(is_hidden: false).limit(3)
  end
end
