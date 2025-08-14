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
    
    # return redirect_to confirmation_success_path if subscriber.nil? || subscriber.confirmed_at.present?
    
    if subscriber.nil?

      redirect_to confirmation_error_path, alert: "Invalid or missing confirmation token."
    elsif subscriber.confirmed_at.present?

      redirect_to confirmation_error_path, alert: "Email has already been confirmed."
    elsif subscriber.confirmation_sent_at < 48.hours.ago
      # Token expired
      redirect_to confirmation_error_path, alert: "Confirmation token has expired."
    else
      # Success path
      subscriber.update!(
        confirmed_at: Time.current,
        confirmation_token: nil,
        confirmation_sent_at: nil
      )
      subscriber.subscribe("ipo-notifier")
      SubscriptionMailer.with(subscriber: subscriber).welcome.deliver_now
      redirect_to confirmation_success_path
    end
  end
  
  def confirmation_success
    render layout: false
  end
  
  def confirmation_error
    render layout: false
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end


# def confirmation
  #   subscriber = Subscriber.find_by(confirmation_token: params[:token])

  #   # if subscriber.nil?
  #   #   redirect_to confirmation_error_path, alert: "Invalid or missing confirmation token."
  #   # elsif subscriber.confirmed_at.present?
  #   #   redirect_to confirmation_error_path, alert: "Email has already been confirmed."
  #   # elsif subscriber.confirmation_sent_at < 48.hours.ago
  #   #   redirect_to confirmation_error_path, alert: "Confirmation token has expired."
  #   # else

  #   subscriber.update!(
  #     confirmed_at: Time.current,
  #     confirmation_token: nil,
  #     confirmation_sent_at: nil
  #   )
  #   subscriber.subscribe("ipo-notifier")
  #   SubscriptionMailer.with(subscriber: subscriber).welcome.deliver_now
  #   # end
  # end