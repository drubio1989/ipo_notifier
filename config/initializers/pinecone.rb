Pinecone.configure do |config|
  config.api_key = Rails.application.credentials.pinecone.api_key
  config.host = Rails.application.credentials.pinecone.host
end