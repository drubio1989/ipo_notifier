class BrowserUseAgent < ApplicationAgent
  def navigate
    @message = "Cats go.."

    prompt message: @message
  end

  def click
    @message = "Cats go.."

    prompt message: @message
  end

  def extract_text
    @message = "Cats go.."

    prompt message: @message
  end

  def screenshot
    @message = "Cats go.."

    prompt message: @message
  end
end
