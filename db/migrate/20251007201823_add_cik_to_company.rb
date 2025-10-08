class AddCikToCompany < ActiveRecord::Migration[8.0]
 def change
  add_column :companies, :cik, :string
 end
end
