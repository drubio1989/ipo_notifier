class VoyageEmbedder
  MODEL_NAME = "voyage-finance-2"
  BATCH_SIZE = 500 # safely below the 1000 limit

  def initialize(client: VoyageAI::Client)

  end

  def embed(chunks)
    all_embeddings = []

    chunks.each_slice(BATCH_SIZE) do |batch|
      response = VoyageAI::Client.new.embed(batch,
        model: MODEL_NAME,
      )

      all_embeddings << response.embeddings
    end

    all_embeddings
  end
end
