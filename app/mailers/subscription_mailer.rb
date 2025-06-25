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

  def test_email
    mail(
      to: 'drubio1989@gmail.com',
      subject: 'Test Email from IPO Notifier',
      body: 'This is a test email sent from Fly.io via AWS SES.'
    )
  end
end
