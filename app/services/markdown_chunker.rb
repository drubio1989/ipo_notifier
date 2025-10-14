require "langchain"

class MarkdownChunker
  def initialize(file_path:, chunk_size: 1000, chunk_overlap: 200)
    @file_path = file_path
    @chunk_size = chunk_size
    @chunk_overlap = chunk_overlap
  end

  def call
    splitter = Langchain::Chunker::Markdown.new(
      File.read(@file_path),
      chunk_size: @chunk_size,
      chunk_overlap: @chunk_overlap
    )

    splitter.chunks
  end
end
