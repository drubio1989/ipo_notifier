class SesNotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'net/http'
  require 'uri'

  def receive
    sns_message = JSON.parse(request.body.read)

    case sns_message['Type']
    when 'SubscriptionConfirmation'
      confirm_subscription(sns_message)
    when 'Notification'
      notification = JSON.parse(sns_message['Message'])
      case notification['notificationType']
      when 'Bounce'
        handle_bounce(notification['bounce'])
      when 'Complaint'
        handle_complaint(notification['complaint'])
      else
        Rails.logger.warn "Unhandled notificationType: #{notification['notificationType']}"
      end
      head :ok
    else
      Rails.logger.warn "Unhandled SNS message type: #{sns_message['Type']}"
      head :bad_request
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}"
    head :bad_request
  rescue => e
    Rails.logger.error "Unexpected error: #{e.message}"
    head :internal_server_error
  end

  private

  def confirm_subscription(message)
    subscribe_url = message['SubscribeURL']
    uri = URI.parse(subscribe_url)
    Net::HTTP.get(uri)
    Rails.logger.info "Confirmed SNS subscription"
    head :ok
  rescue => e
    Rails.logger.error "Failed to confirm subscription: #{e.message}"
    head :internal_server_error
  end

  def handle_bounce(bounce)
    bounced_emails = bounce['bouncedRecipients'].map { |r| r['emailAddress'] }
    bounce_type = bounce['bounceType']

    bounced_emails.each do |email|
      subscriber = Subscriber.find_by(email: email)
      next unless subscriber

      if bounce_type == 'Permanent'
        subscriber.update(email_status: 'bounced', bounce_count: 1)
      else
        subscriber.increment!(:bounce_count)
        if subscriber.bounce_count >= 3
          subscriber.update(email_status: 'bounced')
        end
      end
    end
  end

  def handle_complaint(complaint)
    complained_emails = complaint['complainedRecipients'].map { |r| r['emailAddress'] }
    Subscriber.where(email: complained_emails).update_all(email_status: 'complained')
  end
end
