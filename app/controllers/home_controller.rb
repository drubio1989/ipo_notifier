class HomeController < ApplicationController

  def index
    @ipo_calendar_data = JSON.parse HTTParty.get(ENV['IPO_CALENDAR_LAMBDA_URL']).body, symbolize_names: true
  end

  def subscribe
    email = params[:email]

    response = HTTParty.post(
      ENV['SUBSCRIBE_EMAIL_LAMBDA_URL'], 
      body: JSON.generate({ email: email }), 
      headers: { 'Content-Type' => 'application/json' }
    )

    respond_to do |format|
      if response.code == 201
        SubscriptionMailer.with(email: email).subscribe.deliver_later
        @message = "Thank you for subscribing!"
      end

      format.turbo_stream
    end
  end
end