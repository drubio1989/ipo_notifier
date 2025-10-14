class FinanceController < ApplicationController
  def research
    response = FinancialResearchAgent.with(
      message: "What is Mr. Wong Kok Seng's role?",
    ).research.generate_now
    
    render json: {
      content: response.message.content,
    }
  end
end