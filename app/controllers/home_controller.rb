class HomeController < ApplicationController

  def index
    @ipo_calendar_data = HTTParty.get(ENV['IPO_CALENDAR_LAMBDA_URL'])
  end
end