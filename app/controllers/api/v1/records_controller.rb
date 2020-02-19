class Api::V1::RecordsController < ApplicationController

  # GET /api/v1/records/test
  # For testing serialization of records on the client
  def test
    @records = Record.limit(10)
  end
end
