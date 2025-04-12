class SubscribersController < ApplicationController

  def create
    @subscriber = Subscriber.new(subscriber_params)
    if @subscriber.save
      SubscriptionMailer.with(subscriber: @subscriber).subscribe.deliver_now
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

  def unsubscribe
    subscriber = Subscriber.find_by(unsubscribe_token: params[:token])
    email = subscriber.email
    subscriber.destroy
    SubscriptionMailer.with(email: email).unsubscribe.deliver_now
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end