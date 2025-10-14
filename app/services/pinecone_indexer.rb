# app/services/pinecone_indexer.rb
require "pinecone"

class PineconeIndexer
  def initialize(index_name:)
    @index_name = index_name
    @client = Pinecone::Client.new
    @index = @client.index(@index_name)
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
end
