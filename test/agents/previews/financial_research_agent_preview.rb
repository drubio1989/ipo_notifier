# Preview all agent views/prompts templates at http://localhost:3000/active_agent/agents/financial_research_agent
class FinancialResearchAgentPreview < ActiveAgent::Preview
  # Preview this email at http://localhost:3000/active_agent/agents/financial_research_agent/research
  def research
    FinancialResearchAgent.research
  end
end
