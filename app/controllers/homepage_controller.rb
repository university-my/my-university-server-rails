class HomepageController < ApplicationController
  def home
    @title = "Мій Університет"
    
    # Find random recod
    random_record = Record.find(Record.pluck(:id).sample)
    @university = random_record.university
    @records = [random_record]
    @records_days = @records.group_by { |t| t.start_date }
  end
end
