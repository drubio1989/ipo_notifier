class Company < ApplicationRecord
  has_many :conversations, dependent: :destroy
  
  def snake_case_name
    name.to_s.gsub(/[ ,.]/, '').underscore
  end
  
  def s1_filing
    return if cik == "0" * 10
    begin
      response = HTTParty.get("https://data.sec.gov/submissions/CIK#{cik.rjust(10, "0")}.json", headers: {
        "User-Agent" => "Ipo Notifier (info@iponotifier.com)"
      })
      
      data = response.parsed_response

      filings = data.dig("filings", "recent")
      return unless filings

      s1_index = filings["form"].find_index { |f| ["S-1", "S-1/A", "F-1", "F-1/A"].include?(f) }
      return unless s1_index

      s1_accession = filings["accessionNumber"][s1_index]
      s1_doc = filings["primaryDocument"][s1_index]

      "https://www.sec.gov/Archives/edgar/data/#{cik}/#{s1_accession.delete('-')}/#{s1_doc}"
    rescue StandardError => e
      Rails.logger.error("SEC filing fetch failed for CIK #{cik}: #{e.class} - #{e.message}")
      nil
    end
  end
end
