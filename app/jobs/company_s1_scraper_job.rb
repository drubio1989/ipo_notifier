class CompanyS1ScraperJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: 30.seconds, attempts: 5

  def perform(*args)
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
