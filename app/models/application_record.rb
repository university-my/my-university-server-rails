class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Peform network request and parse JSON
  def self.perform_request(url)
    # Init URI
    uri = URI(url)

    if uri.nil?
      # Add error
      error_message = "Invalid URI"
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Perform request
    response = Net::HTTP.get_response(uri)
    if response.code != '200'
      # Add error
      error_message = "Server responded with code #{response.code} for GET #{uri}"
      # Log invalid URI
      Rails.logger.error(error_message)
      return
    end

    # Parse JSON
    json = JSON.parse(response.body)

    return json
  end

  # Reset increment of primary key (ID)
  def self.reset_increment
    ActiveRecord::Base.connection.execute("DELETE FROM SQLITE_SEQUENCE WHERE name='#{table_name}'")
  end

end
