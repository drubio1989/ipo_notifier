class HomeController < ApplicationController

  def index
    @ipo_calendar_data = HTTParty.get(ENV['IPO_CALENDAR_LAMBDA_URL'])
  end

  def subscribe
    email = params[:email]

    if email.blank?
      @errors = { email: ["can't be blank"] }
      render partial: "subscribe_form", status: :unprocessable_entity
      return
    end
    
    response = HTTParty.post(
      ENV['SUBSCRIBE_EMAIL_LAMBDA_URL'], 
      body: JSON.generate({ email: params[:email] }), 
      headers: { 'Content-Type' => 'application/json' }
    )

    @message = "Thank you for subscribing!"

    respond_to do |format|
      format.turbo_stream
    end
  end
end