class SubscribersController < ApplicationController

  def create
    @subscriber = Subscriber.new(subscriber_params)
    if @subscriber.save
      SubscriptionMailer.with(subscriber: @subscriber).confirm.deliver_later
      
      @message_type = :success
      @message = "Thanks for signing up! Please check your email and click the confirmation link to activate your subscription."
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
      SubscriptionMailer.with(subscriber: @subscriber).subscribe.deliver_later
    end
  end

  def unsubscribe
    subscriber = Subscriber.find_by(unsubscribe_token: params[:token])

    unless subscriber
      head :not_found and return
    end

    email = subscriber.email
    subscriber.destroy
    SubscriptionMailer.with(email: email).unsubscribe.deliver_later

    head :no_content
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end