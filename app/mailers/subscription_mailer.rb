class SubscriptionMailer < ApplicationMailer
  default from: "iponotifier@somewhere.com"

  def subscribe
    @subscriber = params[:subscriber]
    
    @email = params[:email]
    mail(to: @email, subject: "IPO Notifier Subscription Confirmation")
  end

  def unsubscribe
    @email = params[:email]
    mail(to: @email, subject: "IPO Notifier Cancelled Subscription")
  end
end
