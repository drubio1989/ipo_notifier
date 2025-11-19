# lib/tasks/scrape_companies.rake
require 'csv'

namespace :scrape do
  desc "Scrape iposcoop.com and save company data"
  task company_data: :environment do    
    CompanyScraperJob.perform_now
  end
  
  desc "Scrape a company's cik number and s1 filing url"
  task company_cik_and_s1_url: :environment do 
    CompanyCikScraperJob.perform_now
  end
  
  desc "Scrape a company's s1 filing document"
  task company_s1_file: :environment do  
    CompanyS1ScraperJob.perform_now
  end
    
  desc "Report which companies have missing CIKs and/or no S-1 filing"
  task report_unretrievable_companies: :environment do
    tmp_folder = Rails.root.join("tmp/s1_filings/unretrievable")
    FileUtils.mkdir_p(tmp_folder)

    file_path = tmp_folder.join("unretrievable_companies.csv")

    CSV.open(file_path, "w", write_headers: true, headers: ["name", "symbol"]) do |csv|
      Company.where(cik: "0" * 10).find_each do |company|
        csv << [company.name, company.symbol]
      end
    end

    puts "✅ Wrote #{Company.where(cik: '0' * 10).count} companies to #{file_path}"
  end
end
