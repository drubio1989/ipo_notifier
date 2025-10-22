require 'httparty'

class Company < ApplicationRecord
  has_many :conversations, dependent: :destroy
  
  def snake_case_name
    name.gsub(" ", "").gsub(",", "").gsub(",", "").gsub(".", "").underscore
  end
  
  def s1_filing
    return if cik == "#{0 * 10}"
    url = "https://data.sec.gov/submissions/CIK#{cik.rjust(10, "0")}.json"
    response = HTTParty.get(url, headers: {
      "User-Agent" => "Ipo Notifier (info@iponotifier.com)"
    })
    
    s1_index = response["filings"]["recent"]["form"].find_index { |form_type| ["S-1", "S-1/A", "F-1", "F-1/A"].include?(form_type) }
    s1_accession_number = response["filings"]["recent"]["accessionNumber"][s1_index]
    s1_form_name = response["filings"]["recent"]["primaryDocument"][s1_index]
    
    "https://www.sec.gov/Archives/edgar/data/#{cik}/#{s1_accession_number.gsub("-", "")}/#{s1_form_name}"
  end
end
