class AddConversationAndMessageTables < ActiveRecord::Migration[8.0]
    def change
    create_table :conversations do |t|
      t.string :title
      t.timestamps
    end

    create_table :messages do |t|
      t.references :conversation, foreign_key: true
      t.string :role            # "user" or "assistant"
      t.text :content
      t.timestamps
    end
  end

end
