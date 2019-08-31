class HomepageController < ApplicationController
  def home
    @title = "Мій Університет"
    
    # Find random recod
    random_record = Record.where(university_id: 1)
      .where("start_date > ?", DateTime.current)
      .order("RANDOM()").first
    if random_record
      @university = random_record.university
      @records = [random_record]
      @records_days = @records.group_by { |t| t.start_date }
    end
  end
end
