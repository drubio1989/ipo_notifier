class Subscriber < ApplicationRecord
  before_save :generate_unsubscribe_token

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email_status, inclusion: { in: %w(active bounced complained) }

  private

  def generate_unsubscribe_token
    self.unsubscribe_token = Digest::SHA256.hexdigest(self.email + self.created_at.to_s)
  end
end
