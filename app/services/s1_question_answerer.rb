# app/services/s1_question_answerer.rb
require "openai"

class S1QuestionAnswerer
  def initialize
    @embedder = VoyageAIEmbedder.new
    @retriever = PineconeQuery.new
    @llm = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai, :api_key))
  end

  def answer(question, top_k: 5)
    # 1️⃣ Create embedding for the question
    query_embedding = @embedder.embed([question]).first

    # 2️⃣ Retrieve relevant chunks from Pinecone
    results = @retriever.query(query_embedding, top_k: top_k)
    context = results.map { |r| r[:text] }.join("\n---\n")

    # 3️⃣ Construct the LLM prompt
    prompt = <<~PROMPT
      You are a financial analyst AI assistant. 
      Answer the following question based ONLY on the S1 filing content provided.

      Question:
      #{question}

      Context:
      #{context}

      Answer:
    PROMPT

    # 4️⃣ Generate an answer with OpenAI
    response = @llm.chat(
      parameters: {
        model: "gpt-4o-mini",  # or "gpt-4-turbo"
        messages: [
          { role: "system", content: "You are a helpful financial assistant." },
          { role: "user", content: prompt }
        ],
        temperature: 0.2
      }
    )

    {
      answer: response.dig("choices", 0, "message", "content"),
      sources: results
    }
  end
end
