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
    response = HTTParty.get("https://#{INDEX_HOST}/namespaces", 
      headers: { 
          "Api-Key" => "#{API_KEY }",
          "X-Pinecone-API-Version" => "#{API_VERSION }"
        }
    )
    { code: response.code, body: response.parsed_response }
  end
  
 def delete_namespace(namespace)
    url = "https://#{INDEX_HOST}/namespaces/#{namespace}"
    headers = {
      "Api-Key" => API_KEY,
      "X-Pinecone-API-Version" => API_VERSION,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    response = HTTParty.delete(url, headers: headers)
    {
      code: response.code,
      body: response.parsed_response
    }
    rescue => e
    { error: e.message }
    
    puts response
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

  def upsert(embeddings)   
    vectors = chunks.each_with_index.map do |chunk, i|
      {
        id: "#{ccompany.snake_case_name}document#{i}chunk#{i}",
        values: embeddings[i],        
        metadata: { 
          company: "#{company.snake_case_name}"
        } 
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