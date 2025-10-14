class FinancialResearchAgent < ApplicationAgent
  generate_with :openai, model: "gpt-4o-mini"
  
  before_action :set_rag_context
    
  def research
    prompt(
      context_type: :html
    )
  end
  
  private
  
  def set_rag_context
    @question = params[:message]
    query_embedding = voyage.embed([@question]).first
    results = pinecone.query(query_embedding)
    @context = results.map { |r| r[:text] }.join("\n---\n")
  end
  
  def pinecone
    @pinecone ||= PineconeQuery.new
  end
  
  def voyage
    @embedder = VoyageAIEmbedder.new
  end
end
