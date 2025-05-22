# app/controllers/ses_notifications_controller.rb
class SesNotificationsController < ApplicationController
  # Skip CSRF check since SNS won't send your Rails CSRF token
  skip_before_action :verify_authenticity_token

  require 'net/http'
  require 'uri'

  def receive
    sns_message = JSON.parse(request.body.read)

    case sns_message['notificationType']
    when 'Bounce'
      handle_bounce(sns_message['notificationType']['bounce'])
    when 'Complaint'
      handle_complaint(sns_message['notificationType']['complaint'])
    else
      head :bad_request
    end
  rescue JSON::ParserError
    head :bad_request
  end

  private

  def handle_bounce(bounce)
    bounced_emails = bounce['bouncedRecipients'].map { |r| r['emailAddress'] }
    Rails.logger.info("Bounced emails: #{bounced_emails.inspect}")

    # TODO: Your logic here: e.g., mark these emails as bounced in your DB
    # Example:
    # User.where(email: bounced_emails).update_all(bounced: true)
  end

  def handle_complaint(complaint)
    complained_emails = complaint['complainedRecipients'].map { |r| r['emailAddress'] }
    Rails.logger.info("Complaint emails: #{complained_emails.inspect}")

    # TODO: Your logic here: e.g., mark these emails as complained in your DB
  end
end
