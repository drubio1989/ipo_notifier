class SubscriptionMailer < ApplicationMailer
  default from: "iponotifier@somewhere.com"

  def subscribe
    email = params[:email]
    mail(to: email, subject: "IPO Notifier Subscription Confirmation")
  end

  def unsubscribe
    email = params[:email]
    mail(to: email, subject: "IPO Notifier Unsubscribed Confirmation")
  end
end
