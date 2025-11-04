# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation

  after_create_commit -> {
    broadcast_append_to("messages_for_conversation_#{conversation_id}",
      target: "chat-box", # DOM id
      partial: "messages/message", # view
      locals: { msg: self }
    )
  }
end
