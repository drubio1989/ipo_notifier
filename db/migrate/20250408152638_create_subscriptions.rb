class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscribers do |t|
      t.timestamps
      t.string :email
    end
  end
end
