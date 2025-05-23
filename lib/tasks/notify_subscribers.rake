namespace :subscribers do
  desc "Send email to subscribers about companies expected to trade tomorrow"
  task notify: :environment do
    begin
      start_date = Date.tomorrow.beginning_of_day

      companies = Company.where(expected_to_trade: start_date)
      # debugger
      return if companies.empty?

      Subscriber.where(email_status: 'active').find_each do |subscriber|
        # debugger
        IpoNotifierMailer.with(subscriber: subscriber, ipos: companies.to_a).notify_subscriber.deliver_now
      end
    rescue => e
      Rails.logger.error("Trade Notification Error: #{e.message}")
      puts "An error occurred: #{e.message}"
    end
  end
end