require "capybara"
require "capybara/cuprite"

class BrowserUseAgent < ApplicationAgent
  generate_with :openai, model: "gpt-4"
  
  class_attribute :browser_session, default: nil
   
  def navigate
    setup_browser_if_needed

    @s1_filing_url = params[:s1_filing_url]
    Rails.logger.info "Navigating to #{@s1_filing_url}"

    begin
      browser = Ferrum::Browser.new
      page = browser.create_page
      page.go_to(@s1_filing_url)

      # Extract the raw HTML
      html = page.body
      puts html
      # # Parse with Nokogiri
      # doc = Nokogiri::HTML(html)

      # # Extract Title
      # title = doc.at("title")&.text&.strip

      # # Extract the "Risk Factors" section
      # risk_section = extract_risk_factors(doc)

      # # Summarize with LLM via ActiveAgent
      # summary = generate_summary(title, risk_section)

      # Store results
      {
        url: @s1_filing_url,
        title: title,
        summary: summary,
        risk_factors: risk_section
      }

    rescue => e
      Rails.logger.error "Navigation failed: #{e.message}"
      { error: e.message }
    ensure
      browser&.quit
    end
  end
  
  private 
  
  def setup_browser_if_needed
    return if self.class.browser_session

    unless Capybara.drivers[:cuprite_agent]
      Capybara.register_driver :cuprite_agent do |app|
        Capybara::Cuprite::Driver.new(
          app,
          window_size: [1920, 1080],
          browser_options: {
            "no-sandbox": nil,
            "disable-gpu": nil,
            "disable-dev-shm-usage": nil
          },
          inspector: false,
          headless: true,
          browser_options: { "user-agent": "Ipo Notifier (info@iponotifier.com)" }
        )
      end
    end

    self.class.browser_session = Capybara::Session.new(:cuprite_agent)
  end
  

  # def click
  #   @message = "Cats go.."

  #   prompt message: @message
  # end

  # def extract_text
  #   @message = "Cats go.."

  #   prompt message: @message
  # end

end
