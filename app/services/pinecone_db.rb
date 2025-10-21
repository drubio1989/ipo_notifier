require "pinecone"
require "httparty"
require "json"

INDEX_HOST = Rails.application.credentials.pinecone.host
API_VERSION = "2025-10"
API_KEY = Rails.application.credentials.pinecone.api_key

class PineconeDB
  def initialize
    @client = Pinecone::Client.new
    @index = @client.index(Rails.application.credentials.pinecone.index)
  end
  
  def list_namespaces
    puts "https://#{INDEX_HOST}/namespaces"
    response = HTTParty.get("https://#{INDEX_HOST}/namespaces", 
      headers: { 
          "Api-Key" => "#{API_KEY }",
          "X-Pinecone-API-Version" => "#{API_VERSION }"
        }
    )
    { code: response.code, body: response.parsed_response }
  end
  
  def create_company_namespaces    
    Company.all.map do |company|
      response = HTTParty.post("https://#{INDEX_HOST}/namespaces", 
        body: {
          name: company.name,
          schema: {
          fields: { 
                document_id: {filterable: true},
                document_title: {filterable: true},
                chunk_number: {filterable: true},
                document_url: {filterable: true},
                created_at: {filterable: true}
              }
            }
          }.to_json, 
        headers: { 
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "Api-Key" => "#{API_KEY}",
          "X-Pinecone-API-Version" => "#{API_VERSION}"
        }
      )
      { company: company.name, code: response.code, body: response.parsed_response }
   end
  end

  # chunks: array of Langchain::Chunk
  # embeddings: array of arrays (from VoyageAI)
  def upsert(chunks, embeddings)
    raise "Chunks and embeddings must have same size" unless chunks.size == embeddings.size

    vectors = chunks.each_with_index.map do |chunk, i|
      {
        id: SecureRandom.uuid,         # unique ID for Pinecone
        values: embeddings[i],         # embedding vector
        metadata: { text: chunk.text } # optional metadata
      }
    end

    # Upsert to Pinecone (can batch if large)
    @index.upsert(vectors: vectors)
  end
  
  
  # query_text: string to search
  # top_k: number of results to return
  def query(query_embedding, top_k: 5)
    result = @index.query(
      vector: query_embedding,
      top_k: top_k,
      include_metadata: true
    )

    # Returns array of {id, score, metadata}
    result["matches"].map do |match|
      {
        id: match["id"],
        score: match["score"],
        text: match["metadata"]["text"]
      }
    end
  end
end