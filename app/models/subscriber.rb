class Subscriber < ApplicationRecord
  before_create :generate_confirmation_token
  before_create :generate_unsubscribe_token

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email_status, inclusion: { in: %w(active bounced complained) }
  
  has_subscriptions

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(20)
    self.confirmation_sent_at = Time.current
  end

  def generate_unsubscribe_token
    self.unsubscribe_token = Digest::SHA256.hexdigest(self.email + self.created_at.to_s)
  end
end
