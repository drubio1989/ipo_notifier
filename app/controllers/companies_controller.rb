# app/controllers/conversations_controller.rb
class CompaniesController < ApplicationController
  layout "conversation"
    
  def show
    @company = Company.includes(conversations: :messages).find(params[:id])
    @conversation = @company.conversations.where(visitor_token: @visitor_token).first
    @conversation = Conversation.create!(company: @company, visitor_token: @visitor_token) if @conversation.nil?
    @message = Message.new
  end
end
