class CompanyCikScraperJob < ApplicationJob
  queue_as :default

  retry_on HTTParty::Error, wait: 30.seconds, attempts: 5

  def perform(*args)
    companies = Company.all

    response = HTTParty.get(
      "https://www.sec.gov/files/company_tickers.json",
      headers: { "User-Agent" => "Ipo Notifier (info@iponotifier.com)" }
    )

    sec_data = response.values
    sec_by_symbol = sec_data.index_by { |c| c["ticker"]&.upcase }
    sec_by_name   = sec_data.index_by { |c| c["title"]&.downcase }

    companies.each do |company|
      match =
        sec_by_symbol[company.symbol&.upcase] ||
        sec_by_name[company.name&.downcase]

      cik = match ? match["cik_str"].to_s : "0000000000"
      
      next if (company.cik.present? && company.cik != "0000000000" )|| company.s1_filing_url.present?
      company.update(
        cik: cik,
        s1_filing_url: company.s1_filing
      )
    end
  end
end

