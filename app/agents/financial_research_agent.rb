class FinancialResearchAgent < ApplicationAgent
  generate_with :openai, model: "gpt-4o-mini", stream: true
  
  before_action :set_rag_context
  
  on_stream :broadcast_message
  
  def research
    prompt(
      context_type: :html
    )
  end
  
  def broadcast_message
    @conversation = params[:conversation]
    response = generation_provider.response
    delta = stream_chunk&.delta

    @assistant_message ||= create_assistant_message

    delta.present? ? append_delta(delta) : finalize_message(response)

    broadcast_to_frontend(delta, response)
    cleanup_if_done(delta)
  end
  
  private
  
  def create_assistant_message
    @conversation.messages.create!(role: "assistant", content: "")
  end

  def append_delta(delta)
    @assistant_message.update!(content: "#{@assistant_message.content}#{delta}")
  end

  def finalize_message(response)
    @assistant_message.update!(content: response.message.content)
  end

  def broadcast_to_frontend(delta, response)
    ActionCable.server.broadcast(
      "conversation_#{@conversation.id}",
      {
        message_id: @assistant_message.id,
        delta: delta || response.message.content,
        done: delta.nil?,
        role: "assistant"
      }
    )
  end

  def cleanup_if_done(delta)
    @assistant_message = nil if delta.nil?
  end
    
  def broadcast_to_frontend(delta, response)
    ActionCable.server.broadcast(
      "conversation_#{@conversation.id}",
      {
        message_id: @assistant_message.id,
        delta: delta || response.message.content,
        done: delta.nil?,
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
