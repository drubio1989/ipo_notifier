# lib/tasks/scrape_companies.rake
require 'httparty'
require 'nokogiri'
require "find"

namespace :scrape do
  desc "Scrape IPO Scoop and save company data"
  task companies: :environment do    
    CompanyScraperJob.perform_later
    # puts "Removing old data......"
    
  #  filings_path = Rails.root.join("tmp", "s1_filings")

  #   if Dir.exist?(filings_path)
  #     Find.find(filings_path) do |path|
  #       File.delete(path) if File.file?(path)
  #     end
  #   else
  #     FileUtils.mkdir_p(filings_path)
  #   end
    
    # Company.destroy_all
   
  end
  
  desc "Scrape a company's cik number and s1 filing url"
  task company_cik_and_s1: :environment do
    puts 'Starting......'
    
    
    companies = Company.all
    
    url = "https://www.sec.gov/files/company_tickers.json"
    response = HTTParty.get(url, headers: {
      "User-Agent" => "Ipo Notifier (info@iponotifier.com)"
    })

    unless response.success?
      puts "Failed to fetch data"
      return   # exits the method immediately
    end
      
    sec_data = response.values.map do |company|
      company.transform_keys do |key|
        key == "ticker" ? company["ticker"] : key
      end
    end
     
    companies.each do |company|
      # First try to match by symbol
      match = sec_data.find { |listing| listing.key?(company.symbol) }

      # Fallback: try matching by company name if no symbol match
      if match.nil?
        match = sec_data.find { |listing| listing["title"].to_s.downcase == company.name.to_s.downcase }
      end

      # Update the company CIK
      if match.nil?
        company.update(cik: "0000000000")  # 10 zeros
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
      filename = "#{company.uuid}.md"
      file_path = tmp_folder.join(filename)

      # Write Markdown file (overwrite if it exists)
      File.write(file_path, "##{plain_text}")

      puts "Saved to #{file_path} (overwritten if existed)"
      file_path
    end
  end
end
