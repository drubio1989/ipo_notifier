class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :company
      t.string :symbol
      t.string :lead_managers
      t.string :no_of_shares
      t.string :price_low
      t.string :price_high
      t.string :estimated_volume
      t.datetime :expected_to_trade

      t.timestamps
    end
  end
end
