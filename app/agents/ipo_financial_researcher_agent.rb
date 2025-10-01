class IpoFinancialResearcherAgent < ApplicationAgent
  def research
    @message = "Cats go.."

    prompt message: @message
  end
end
