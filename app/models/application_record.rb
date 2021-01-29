class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Peform network request and parse JSON
  def self.perform_request(url)
    # Init URI
    uri = URI(url)

    # Perform request
    response = Net::HTTP.get_response(uri)

    # Parse JSON
    json = JSON.parse(response.body)

    return json
  end

  # Reset increment of primary key (ID)
  def self.reset_increment
    ActiveRecord::Base.connection.execute("DELETE FROM SQLITE_SEQUENCE WHERE name='#{table_name}'")
  end

end
