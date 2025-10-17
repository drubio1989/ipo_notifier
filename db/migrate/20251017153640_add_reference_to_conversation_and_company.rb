class AddReferenceToConversationAndCompany < ActiveRecord::Migration[8.0]
  
  def change
    add_reference :conversations, :company, foreign_key: true
  end
end

