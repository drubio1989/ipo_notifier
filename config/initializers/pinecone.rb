Pinecone.configure do |config|
  config.api_key = Rails.application.credentials.dig(:pinecone, :api_key)
  config.host = Rails.application.credentials.dig(:pinecone, :host)
end