class SubscriptionMailer < ApplicationMailer

  def confirm
    @subscriber = params[:subscriber]
    mail(to: @subscriber.email, subject: "Please confirm your subscription to IPO Notifier")
  end

  def welcome
    @subscriber = params[:subscriber]
    mail(to: @subscriber.email, subject: "IPO Notifier Subscription Confirmation")
  end

  def unsubscribe
    @email = params[:email]
    mail(to: @email, subject: "IPO Notifier Cancelled Subscription")
  end

end
