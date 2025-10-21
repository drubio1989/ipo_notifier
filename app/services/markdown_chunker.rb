require "langchain"

class MarkdownChunker
  def initialize(file_path:, chunk_size: 850, chunk_overlap: 100)
    @file_path = file_path
    @chunk_size = chunk_size
    @chunk_overlap = chunk_overlap
  end

  def process_file
    splitter = Langchain::Chunker::Markdown.new(
      File.read(@file_path),
      chunk_size: @chunk_size,
      chunk_overlap: @chunk_overlap
    )

    splitter.chunks.map { |chunk| chunk.text }
  end
end
