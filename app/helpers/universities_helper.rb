module UniversitiesHelper

  def self.getDate(timeStart, dayNumber, lessonWeek)

    # First or second semest
    isSecondSemester = Date.current.month < 6

    # First study month
    firstStudyMonth = isSecondSemester ? 1 : 8 # september or february

    # First study day
    firstStudyDay = 1
    if isSecondSemester
      firstStudyDay = (Date.new(Date.current.year, firstStudyMonth, 1) + 8.days).day
    end

    # Pair date
    date = Date.new(Date.current.year, firstStudyMonth, firstStudyDay)
    daysCount = Integer(dayNumber)
    date.at_beginning_of_week + daysCount.days

    if lessonWeek == '2'
      date = date + 7.days
    end

    month = isSecondSemester ? '-02-' : '-09-'

    finalDate = DateTime.parse("#{Date.current.year}#{month}#{date.day}T#{timeStart}")
    return finalDate
    
  end
end
