# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
class SubscriptionMailerPreview < ActionMailer::Preview
   def unsubscribe
    SubscriptionMailer.with(email: "user@example.com").unsubscribe
  end

  def welcome
    subscriber = Subscriber.first || Subscriber.new(email: "user@example.com")
    SubscriptionMailer.with(subscriber: subscriber).welcome
  end

  def confirm
    subscriber = Subscriber.first || Subscriber.new(email: "user@example.com", confirmation_token: "sampletoken123")
    SubscriptionMailer.with(subscriber: subscriber).confirm
  end
end
