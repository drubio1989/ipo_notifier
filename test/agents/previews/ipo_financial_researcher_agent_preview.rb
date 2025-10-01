# Preview all agent views/prompts templates at http://localhost:3000/active_agent/agents/ipo_financial_researcher_agent
class IpoFinancialResearcherAgentPreview < ActiveAgent::Preview
  # Preview this email at http://localhost:3000/active_agent/agents/ipo_financial_researcher_agent/research
  def research
    IpoFinancialResearcherAgent.research
  end
end
