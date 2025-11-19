namespace :subscribers do
  desc "Send email to subscribers about companies expected to trade tomorrow"
  task notify: :environment do
    NotifySubscriberJob.perform_later
  end
end