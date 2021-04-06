class HomepageController < ApplicationController
  def home
    @universities = University.where(is_hidden: false).order('RANDOM()').limit(3)
  end
end
