class FinancialResearchAgent < ApplicationAgent
  generate_with :openai, model: "gpt-4o-mini"
  before_action :set_rag_context
  after_generation :process_response
  
  def research
    prompt(
      context_type: :html
    )
  end
  
  private
  
  def process_response
    content = generation_provider.response.message.content
  
    params[:conversation].messages.create(
      content: content,
      role: "assistant"
    )
  end

  def set_rag_context
    @question = params[:message]
    @company = params[:company]
    embedded_query = VoyageAI::Client.new.embed([@question], model: "voyage-finance-2").embeddings[0]
    response = Pinecone::Client.new.index.query(
      vector: embedded_query,
      top_k: 5,
      include_metadata: true,
      namespace: @company.snake_case_name
    )
   
   @context = response["matches"].map { |match| match["metadata"]["text"] }.join("\n---\n")
  end
end
