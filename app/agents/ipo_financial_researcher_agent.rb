class IpoFinancialResearcherAgent < ApplicationAgent
  generate_with :openai, model: "gpt-4o-mini", instructions: "You are a financial reseacher."
  
  def research
    @message = "Cats go.."

    prompt message: @message
  end
end
