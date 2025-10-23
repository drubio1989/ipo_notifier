VoyageAI.configure do |config|
  config.api_key = Rails.application.credentials.dig(:voyageai,:api_key)
end