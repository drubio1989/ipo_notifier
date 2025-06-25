class AddConfirmationFieldsForSubscriber < ActiveRecord::Migration[8.0]
  def change
    add_column :subscribers, :confirmation_token, :string
    add_column :subscribers, :confirmed_at, :datetime
    add_column :subscribers, :confirmation_sent_at, :datetime

    add_index :subscribers, :confirmation_token, unique: true
  end
end
