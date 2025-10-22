class ConversationsController < ApplicationController
  before_action :set_company
  before_action :set_conversation

  #<ActionController::Parameters {"authenticity_token" => "0e1uY-ZTu6SvWlFp8D7TgGQJodhphvnEGaLcEg2xHzSO3Opa2-MGHUdf0sUjQT_YGidKaDRk8O3Gx9oDX8b_Ug", "message" => {"content" => ""}, "commit" => "Send", "controller" => "conversations", "action" => "create", "company_id" => "46", "id" => "40"} permitted: false>
  def create
    @message = @conversation.messages.create!(
      content: params[:message][:content],
      role: "user"  # optional if you track role
    )

    @agent_response = FinancialResearchAgent.with(
      message: @message.content,
      company: @company
    ).research.generate_now
   
    @conversation.messages.create!(
      content: @agent_response.message.content,
      role: "assistant"
    )
    redirect_to company_path(@company)
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


   #  response = FinancialResearchAgent.with(
    #   message: user_message.content,
    # ).research.generate_now
   