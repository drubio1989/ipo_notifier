class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :company

  def last_messages(limit = 10)
    messages.order(created_at: :asc).last(limit)
  end
end
