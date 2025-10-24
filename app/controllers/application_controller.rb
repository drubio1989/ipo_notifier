class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :set_visitor_token
  
  private 
  
  def set_visitor_token
    cookies.signed[:visitor_token] ||= {
      value: SecureRandom.uuid,
      expires: 1.year.from_now
    }
    
    @visitor_token = cookies.signed[:visitor_token]
  end
end
