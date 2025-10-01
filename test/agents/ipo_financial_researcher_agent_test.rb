require "test_helper"

class IpoFinancialResearcherAgentTest < ActiveAgent::TestCase
  test "research" do
    agent = IpoFinancialResearcherAgent.research
    assert_equal "Research", agent.prompt_context
  end
end
