require 'langchain'

namespace :vector_storage do
  task vectorize_s1_filings: :environment do
    puts "Begin chunking......"
    # Loop through all Markdown files in tmp/s1_filings
    Dir.glob(Rails.root.join("tmp", "s1_filings", "*.md")).each do |file_path|
      puts "Processing file: #{file_path}"
      company = Company.find_by(uuid: File.basename(file_path, ".md"))
      
      splitter = Langchain::Chunker::Markdown.new(
          File.read(file_path),
          chunk_size: 850,
          chunk_overlap:100
        )

      chunks = splitter.chunks.map { |chunk| chunk.text }
     
      puts "Begin embedding....."
      all_embeddings = []
      voyageai = VoyageAI::Client.new
      chunks.each_slice(250) do |batch|
        response = voyageai.embed(batch,
          model: "voyage-finance-2",
        )

        all_embeddings << response.embeddings
      end

      embeddings = all_embeddings.flatten(1)

      puts "Begin uploading to vector storage"
      pinecone = Pinecone::Client.new
      p_index = pinecone.index
      
      vectors = embeddings.map.with_index do |embedding, i|
         {
          id: "#{company.snake_case_name}document#{i}chunk#{i}",
          values: embedding,        
          metadata: { 
            company: company.snake_case_name,
            text: chunks[i]
          } 
        }
      end
      
      p_index.upsert(
        namespace: "#{company.snake_case_name}",
        vectors: vectors
      )
    end
  end
end
