class CompanyS1ScraperJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 30.seconds, attempts: 5

  def perform(*args)
    tmp_folder = Rails.root.join("tmp/s1_filings")
    FileUtils.mkdir_p(tmp_folder)

    Company.where.not(s1_filing_url: nil).each do |company|
      filename = "#{company.uuid}.md"
      file_path = tmp_folder.join(filename)
      
      next if File.exist?(file_path)

      begin
        res = HTTParty.get(
          company.s1_filing_url,
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

        File.write(file_path, "## #{plain_text}")
        puts "✅ Saved #{company.name} to #{file_path}"
      rescue HTTParty::Error, Zlib::Error => e
        puts "⚠️ Failed to fetch or parse #{company.name}: #{e.class} - #{e.message}"
      end
    end
  end
end
