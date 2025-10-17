# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation

end
