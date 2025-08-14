class SubscribersController < ApplicationController

  def create
    @subscriber = Subscriber.new(subscriber_params)
    if @subscriber.save
      SubscriptionMailer.with(subscriber: @subscriber).confirm.deliver_now #Change to deliver_later if there's more user traction
      
      @message_type = :success
      @message = "Please check your email to confirm your subscription."
    else
      @message_type = :error
      @message = "There was a problem with your subscription."
    end
  
  end

  def confirmation
    subscriber = Subscriber.find_by(confirmation_token: params[:token])

    if subscriber.nil?
      render plain: "Invalid or missing confirmation token", status: :not_found
    elsif subscriber.confirmed_at.present?
      render plain: "Email has already been confirmed", status: :unprocessable_entity
    elsif subscriber.confirmation_sent_at < 48.hours.ago
      render plain: "Confirmation token has expired", status: :unprocessable_entity
    else
      subscriber.update!(
        confirmed_at: Time.current,
        confirmation_token: nil,
        confirmation_sent_at: nil
      )
      subscriber.subscribe('ipo-notifier')
      SubscriptionMailer.with(subscriber: subscriber).welcome.deliver_now #Change to deliver_later if there's more user traction
      render plain: "Subscription confirmed! Check your email for a welcome message.", status: :ok
    end
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end