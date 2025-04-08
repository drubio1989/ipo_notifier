class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscribers do |t|
      t.timestamps
      t.string :email, null: false
    end

    add_index :subscribers, :email, unique: true
  end
end
