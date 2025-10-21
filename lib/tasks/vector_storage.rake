# namespace :vector do
#   task vectorize_s1_filings: do
#     puts "Begin chunking......"
    
    
#   end
# end

mdc = MarkdownChunker.new(file_path: File.join(Rails.root, '/tmp/s1_filings/maplight_therapeutics_inc-S1.md'))
chunks = mdc.call.map { |c| c.text }
embeddings = VoyageEmbedder.new.embed(chunks)
