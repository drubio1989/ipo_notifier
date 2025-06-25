require "ostruct"

class IpoNotifierMailerPreview < ActionMailer::Preview

  def notify_subscriber
    subscriber = Subscriber.first || Subscriber.new(email: "user@example.com")
    ipos = [
      OpenStruct.new(
        company: "Acme Corp",
        symbol: "ACME",
        estimated_volume: "5M",
        expected_to_trade: Date.tomorrow,
        lead_managers: "Goldman Sachs",
        no_of_shares: "2M",
        price_high: "$25.00",
        price_low: "$22.00"
      ),
      OpenStruct.new(
        company: "TechNova Inc",
        symbol: "TNV",
        estimated_volume: "8M",
        expected_to_trade: Date.tomorrow,
        lead_managers: "Morgan Stanley",
        no_of_shares: "4M",
        price_high: "$45.00",
        price_low: "$40.00"
      )
    ]

    IpoNotifierMailer.with(subscriber: subscriber, ipos: ipos).notify_subscriber
  end
end