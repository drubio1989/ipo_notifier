class HomeController < ApplicationController

  def index
    response = HTTParty.get(Rails.application.credentials.aws.lambda.ipo_calendar)
    @ipo_calendar_data = JSON.parse(response["body"])
  end
end