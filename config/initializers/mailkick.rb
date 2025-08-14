Mailkick.process_opt_outs_method = lambda do |opt_outs|
  opt_outs.each do |opt_out|

    subscriber = Subscriber.find_by(unsubscribe_token: opt_out.token)

    unless subscriber
      Rails.logger.warn("Unsubscribe attempt with invalid token: #{opt_out.token}")
      next
    end

    email = subscriber.email

    subscriber.unsubscribe("ipo_notifier")

    subscriber.destroy

    SubscriptionMailer.with(email: email).unsubscribe.deliver_later
  end
end