namespace :vector do
  task vectorize_s1_filings: do
    puts "Begin chunking......"
    # Loop through all Markdown files in tmp/s1_filings
    Dir.glob(Rails.root.join("tmp", "s1_filings", "*.md")).each do |file_path|
      puts "Processing file: #{file_path}"
      mdc = MarkdownChunker.new(file_path: file_path)
      chunks = mdc.process_file
      puts "Begin embedding....."
      all_embeddings = []
      voyageai = VoyageAI::Client.new
      chunks.each_slice(500) do |batch|
        response = voyageai.embed(batch,
          model: "voyage-finance-2",
        )

        all_embeddings << response.embeddings
      end

      all_embeddings
      puts "Begin uploading to vector storate"
      # yet to be implemented
      
    end
  end
  puts "Vectorization and storage complete!"
end
