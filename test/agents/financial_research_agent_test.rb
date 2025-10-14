require "test_helper"

class FinancialResearchAgentTest < ActiveAgent::TestCase
  test "research" do
    agent = FinancialResearchAgent.research
    assert_equal "Research", agent.prompt_context
  end
end
