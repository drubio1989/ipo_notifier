# app/services/voyage_ai_embedder.rb
require "httparty"
require "json"

class VoyageAIEmbedder
  include HTTParty
  base_uri "https://api.voyageai.com/v1"

  def initialize
    @headers = {
      "Authorization" => "Bearer #{Rails.application.credentials.voyageai.api_key}",
      "Content-Type" => "application/json"
    }
  end

  # Accepts an array of strings (chunks)
  def embed(texts)
    body = {
      model: "voyage-finance-2",  # <--- updated model
      input: texts
    }.to_json

    response = self.class.post("/embeddings", headers: @headers, body: body)
    raise "VoyageAI API error: #{response.body}" unless response.success?

    # Returns an array of embeddings
    response.parsed_response["data"].map { |d| d["embedding"] }
  end
  
 

  end
