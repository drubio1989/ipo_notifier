class ConversationsController < ApplicationController
  before_action :set_company
  before_action :set_conversation

  def create
   @message = @conversation.messages.create!(
      content: params[:message][:content],
      role: "user"  # optional if you track role
    )
    
    @agent_response = FinancialResearchAgent.with(
      message: params[:message][:content],
      company: @company,
      conversation: @conversation
    ).research.generate_later
   
   
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to company_path(@company) } # fallback
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Failed to send message: #{e.message}"
    redirect_to company_path(@company)
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_conversation
    @conversation = @company.conversations.find(params[:id])
  end
end
