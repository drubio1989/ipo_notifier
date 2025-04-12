class SubscribersController < ApplicationController
  invisible_captcha only: [:create], honeypot: :subscribe

  def create
    @subscriber = Subscriber.new(subscriber_params)
    if @subscriber.save
      # SubscriptionMailer.with(email: @subscriber.email).subscribe.deliver_later
      @message_type = :success
      @message = "Thank you for subscribing!"
    else
      @message_type = :error
      @message = "There was a problem with your subscription."
    end
  
    respond_to do |format|
      format.turbo_stream
    end
  end

  def delete
    email = params[:email]

    respond_to do |format|
      if response.code == 201
        # SubscriptionMailer.with(email: email).subscribe.deliver_later
        @message = "Thank you for subscribing!"
      end

      format.turbo_stream
    end
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end