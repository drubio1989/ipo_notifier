# lib/tasks/scrape_companies.rake
require 'httparty'
require 'nokogiri'

namespace :scrape do
  desc "Scrape IPO Scoop and save company data"
  task companies: :environment do
    puts 'Starting......'
    puts "Removing old data......"
    Company.destroy_all

    puts "Begin Scraping........"
    url = 'https://www.iposcoop.com/ipo-calendar/'
    response = HTTParty.get(url)

    unless response.success?
      puts "Failed to fetch data"
      next
    end

    document = Nokogiri::HTML(response.body)
    rows = document.css('tbody tr')

    company_columns = [
      'Company',
      'Symbol',
      'LeadManagers',
      'NoOfShares',
      'PriceLow',
      'PriceHigh',
      'EstimatedVolume',
      'ExpectedToTrade'
    ]

    rows.each do |tr|
      tds = tr.css('td')
      next if tds.empty?

      company_data = {}

      tds.each_with_index do |td, index|
        break if index >= 8
        field = company_columns[index]

        if index == 7 # ExpectedToTrade date
          date_text = td.text.strip.split(' ').first
          begin
            iso_date =  Date.strptime(date_text, '%m/%d/%Y')
            company_data[field] = iso_date
          rescue => e
            puts "Invalid date: #{date_text}"
          end
        else
          company_data[field] = td.text.strip
        end
      end

      next if company_data['Company'].blank?

      Company.create!(
        company: company_data['Company'],
        symbol: company_data['Symbol'],
        lead_managers: company_data['LeadManagers'],
        no_of_shares: company_data['NoOfShares'],
        price_low: company_data['PriceLow'],
        price_high: company_data['PriceHigh'],
        estimated_volume: company_data['EstimatedVolume'],
        expected_to_trade: company_data['ExpectedToTrade']
      )

      puts "Saved: #{company_data['Company']}"
    end

    puts "Scraping complete."
  end
  
  desc "Scrape a company's cik number and s2 filing url"
  task company_cik_and_s1: :environment do
    puts 'Starting......'
    
    companies = Company.all
    
    url = "https://www.sec.gov/files/company_tickers.json"
    response = HTTParty.get(url, headers: {
      "User-Agent" => "Ipo Notifier (info@iponotifier.com)"
    })

    unless response.success?
      puts "Failed to fetch data"
      next
    end
    
    sec_data = response.values.map do |company|
      company.transform_keys do |key|
        key == "ticker" ? company["ticker"] : key
      end
    end
     
    companies.each do |company|
      match = sec_data.find { |listing| listing.key? company.symbol }
      
      if match.nil?
        company.update(cik: "#{0 * 10}")
      else
        company.update(cik: match["cik_str"].to_s)
      end
    end
    
    companies.each do |company|
      next if company.cik == "#{0 * 10}"
      company.update(s1_filing_url: company.s1_filing)
    end
    
    puts "CIK update complete."
  end
  
  desc "Scrape a company's s1 filing document"
  task company_s1_download: :environment do
    puts "Begin scraping for company's s1 filing document"
    
    companies = Company.where.not(s1_filing_url: nil)
    companies.each do |company|   
      res = HTTParty.get(
          company.s1_filing_url ,
          headers: {
            "User-Agent" => "Ipo Notifier (info@iponotifier.com)",
            "Accept-Encoding" => "gzip, deflate"
          }
        )

      html = case res.headers["content-encoding"]
        when "gzip"
          Zlib::GzipReader.new(StringIO.new(res.body)).read
        when "deflate"
          Zlib::Inflate.inflate(res.body)
        else
          res.body
        end

      html_doc = Nokogiri::HTML(html)
      plain_text = html_doc.text.gsub(/\s+/, " ").strip

      tmp_folder = Rails.root.join("tmp/s1_filings")
      Dir.mkdir(tmp_folder) unless Dir.exist?(tmp_folder)

      # Build filename
      filename = "#{company.company.downcase.gsub(" ","_")}-#{company.symbol}-S1.md"
      file_path = tmp_folder.join(filename)

      # Write Markdown file (overwrite if it exists)
      File.write(file_path, "##{plain_text}")

      puts "Saved to #{file_path} (overwritten if existed)"
      file_path
    end
  end
end
