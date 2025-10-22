class ChangeCompanyCompanyIntoCompanyName < ActiveRecord::Migration[8.0]
  def change
    rename_column :companies, :company, :name
    
    add_column :companies, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_index :companies, :uuid, unique: true
  end
end
