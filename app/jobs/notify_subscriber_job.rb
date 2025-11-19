class NotifySubscriberJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 30.seconds, attempts: 5
  
  def perform(*args)
    start_date = Date.tomorrow.beginning_of_day

    companies = Company.where(expected_to_trade: start_date)
    
    return if companies.empty?

    Subscriber.where(email_status: 'active').find_each do |subscriber|
      IpoNotifierMailer.with(subscriber: subscriber, ipos: companies.to_a).notify_subscriber.deliver_now
    end
  end  
end