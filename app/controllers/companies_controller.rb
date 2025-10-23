# app/controllers/conversations_controller.rb
class CompaniesController < ApplicationController
  layout "conversation"
  
  before_action :clear_conversation
  
  def show
    @company = Company.find(params[:id])
    
    if @company.conversations.any?
      @conversation = @company.conversations.first
    else
      @conversation = Conversation.new
      @conversation.company = @company
      @conversation.save
    end
 
    @message = Message.new
  end

  private
  
  def clear_conversation
    conversation = Conversation.find_by(company_id: params[:id])
    conversation.destroy if conversation.present? 
  end
end
