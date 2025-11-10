require 'langchain'

namespace :vector_storage do
  task vectorize_s1_filings: :environment do
    puts "🚀 Starting vectorization process..."

    Dir.glob(Rails.root.join("tmp", "s1_filings", "*.md")).each do |file_path|
      uuid = File.basename(file_path, ".md")
      company = Company.find_by(uuid: uuid)

      if company.nil?
        puts "⚠️  No company found for file #{file_path}, skipping..."
        next
      end

      puts "🏢 Processing company: #{company.name} (#{uuid})"
      
      #Check to see if company has already been vectorized.
      pinecone = Pinecone::Client.new
      p_index = pinecone.index
      stats = p_index.describe_index_stats
      company_detected_on_pinecone = stats.dig("namespaces", company.snake_case_name)
      
      if company_detected_on_pinecone.present?
        puts "⚠️ #{company.name} has already been uploaded to pinecone, skipping..."
        next
      end
        
      # 1️⃣ Chunk the markdown file
      splitter = Langchain::Chunker::Markdown.new(
        File.read(file_path),
        chunk_size: 850,
        chunk_overlap: 100
      )

      chunks = splitter.chunks.map(&:text)
      puts "🧩 Created #{chunks.size} chunks. Generating embeddings..."

      # 2️⃣ Generate embeddings in batches
      voyageai = VoyageAI::Client.new
      all_embeddings = []

      chunks.each_slice(250).with_index(1) do |batch, idx|
        begin
          response = voyageai.embed(batch, model: "voyage-finance-2")
          all_embeddings.concat(response.embeddings)
          puts "✅  Embedded batch #{idx}/#{(chunks.size / 250.0).ceil}"
        rescue => e
          puts "❌  Embedding batch #{idx} failed: #{e.message}"
        end
      end

      embeddings = all_embeddings

      # 3️⃣ Validate alignment
      if embeddings.size != chunks.size
        puts "⚠️  Embeddings count (#{embeddings.size}) != chunks count (#{chunks.size})"
        next
      end

      # 4️⃣ Diagnostic payload info
      embedding_dim = embeddings.first.size
      approx_kb = (embeddings.size * embedding_dim * 4 / 1024.0).round(2)
      puts "📏 Embeddings: #{embeddings.size} | Dim: #{embedding_dim} | ~#{approx_kb} KB total"

      # 5️⃣ Prepare Pinecone vectors
      vectors = embeddings.map.with_index do |embedding, i|
        {
          id: "#{company.snake_case_name}_doc#{i}",
          values: embedding,
          metadata: {
            company: company.snake_case_name,
            text: chunks[i]
          }
        }
      end

      # 6️⃣ Upload to Pinecone safely in batches
      puts "📤 Uploading #{vectors.size} vectors to Pinecone..."

      batch_size = 100  # adjust after diagnostics
      vectors.each_slice(batch_size).with_index(1) do |batch, idx|
        begin
          result = p_index.upsert(
            namespace: company.snake_case_name,
            vectors: batch
          )
          count = result.dig('upsertedCount') || batch.size
          puts "✅  Uploaded batch #{idx} (#{count} vectors)"
        rescue => e
          puts "❌  Upload failed on batch #{idx}: #{e.message}"
        end
      end

      # 7️⃣ Confirm upload success
      begin
        stats = p_index.describe_index_stats
        count = stats.dig("namespaces", company.snake_case_name, "vectorCount")
        puts "🎯 Namespace #{company.snake_case_name} now has #{count} vectors in Pinecone"
      rescue => e
        puts "⚠️  Could not verify upload for #{company.name}: #{e.message}"
      end

      puts "✅  Completed upload for #{company.name}"
      puts "---------------------------------------------"
    end

    puts "🎉 Vectorization complete!"
  end
end
