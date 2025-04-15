class HomeController < ApplicationController
  def index
    start_date = Time.current
    end_date = 7.days.from_now

    @ipo_calendar_data = Company.where(expected_to_trade: start_date..end_date)
  end
end