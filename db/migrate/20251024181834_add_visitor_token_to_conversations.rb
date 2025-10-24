class AddVisitorTokenToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :visitor_token, :string
    add_index :conversations, :visitor_token
    
    remove_column :conversations, :title
  end
end
