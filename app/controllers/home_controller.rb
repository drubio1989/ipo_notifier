class HomeController < ApplicationController
  def index
    @ipo_calendar_data = JSON.parse HTTParty.get(ENV['IPO_CALENDAR_LAMBDA_URL']).body, symbolize_names: true
  end
end