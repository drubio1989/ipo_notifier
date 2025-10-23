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
    delta = stream_chunk&.delta
    conversation = Conversation.find(params[:conversation_id])

    # Only create one assistant message per response
    @assistant_message ||= conversation.messages.create!(role: "assistant", content: "")

    if delta.present?
      # Append chunk progressively
      @assistant_message.update!(content: "#{@assistant_message.content}#{delta}")
    else
      # Final update
      @assistant_message.update!(content: response.message.content)
      @assistant_message = nil
    end

    # Broadcast to frontend
    ActionCable.server.broadcast(
      "conversation_#{conversation.id}",
      {message_id: @assistant_message.id,
      delta: delta || response.message.content,
      done: delta.nil?,
      role: "assistant"}
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
