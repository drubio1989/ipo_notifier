require "test_helper"

class BrowserUseAgentTest < ActiveAgent::TestCase
  test "navigate" do
    agent = BrowserUseAgent.navigate
    assert_equal "Navigate", agent.prompt_context
  end

  test "click" do
    agent = BrowserUseAgent.click
    assert_equal "Click", agent.prompt_context
  end

  test "extract_text" do
    agent = BrowserUseAgent.extract_text
    assert_equal "Extract text", agent.prompt_context
  end

  test "screenshot" do
    agent = BrowserUseAgent.screenshot
    assert_equal "Screenshot", agent.prompt_context
  end
end
