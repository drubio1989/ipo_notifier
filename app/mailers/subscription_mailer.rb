class SubscriptionMailer < ApplicationMailer
  default from: "iponotifier@somewhere.com"

  def subscribe
    email = params[:email]
    mail(to: email, subject: "Thank you for subscribing to I.P.O. Notifier!")
  end
end
