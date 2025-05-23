class AlterSubscriberTable < ActiveRecord::Migration[8.0]
  def change
    add_column :subscribers, :email_status, :string, default: 'active'
    add_column :subscribers, :bounce_count, :integer, default: 0
  end
end
