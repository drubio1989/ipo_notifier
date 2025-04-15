# lib/tasks/scrape_companies.rake
require 'httparty'
require 'nokogiri'

namespace :scrape do
  desc "Scrape IPO Scoop and save company data"
  task companies: :environment do
    puts 'Starting......'
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
            iso_date = Date.parse(date_text).to_datetime
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
end
