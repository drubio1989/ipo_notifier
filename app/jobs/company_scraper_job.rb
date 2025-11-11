class CompanyScraperJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 30.seconds, attempts: 5

  def perform(*args)
    response = HTTParty.get('https://www.iposcoop.com/ipo-calendar/')
    
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
          iso_date =  Date.strptime(date_text, '%m/%d/%Y')
          company_data[field] = iso_date
        else
          company_data[field] = td.text.strip
        end
      end
      
      next if Company.exists?(name: company_data['Company'])
      
      Company.create(
        name: company_data['Company'],
        symbol: company_data['Symbol'],
        lead_managers: company_data['LeadManagers'],
        no_of_shares: company_data['NoOfShares'],
        price_low: company_data['PriceLow'],
        price_high: company_data['PriceHigh'],
        estimated_volume: company_data['EstimatedVolume'],
        expected_to_trade: company_data['ExpectedToTrade']
      )
    end
  end
end
