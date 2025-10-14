# app/services/pinecone_query.rb
require "pinecone"

class PineconeQuery
  def initialize
    @client = Pinecone::Client.new
    @index = @client.index("iponotifier")
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
