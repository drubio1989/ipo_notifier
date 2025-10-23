class FinancialResearchAgent < ApplicationAgent
  generate_with :openai, 
    model: "gpt-4o-mini", 
    stream: true
  
  before_action :set_rag_context
  
  on_stream :broadcast_message
    
  def research
    prompt(
      context_type: :html
    )
  end
  
  private
  
  def broadcast_message
    response = generation_provider.response

    # Determine whether we are receiving an incremental delta or final message
    message = stream_chunk.delta.presence || response.message.content

    ActionCable.server.broadcast(
      "conversation_#{params[:conversation_id]}",
      {
        chunk: message,
        role: "assistant"
      }
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
