# Preview all agent views/prompts templates at http://localhost:3000/active_agent/agents/browser_use_agent
class BrowserUseAgentPreview < ActiveAgent::Preview
  # Preview this email at http://localhost:3000/active_agent/agents/browser_use_agent/navigate
  def navigate
    BrowserUseAgent.navigate
  end

  # Preview this email at http://localhost:3000/active_agent/agents/browser_use_agent/click
  def click
    BrowserUseAgent.click
  end

  # Preview this email at http://localhost:3000/active_agent/agents/browser_use_agent/extract_text
  def extract_text
    BrowserUseAgent.extract_text
  end

  # Preview this email at http://localhost:3000/active_agent/agents/browser_use_agent/screenshot
  def screenshot
    BrowserUseAgent.screenshot
  end
end
