class AddCikToCompany < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :cik, :string
    add_index :companies, :cik, unique: true
  end
end
