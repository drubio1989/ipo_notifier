class ConversationsController < ApplicationController
  before_action :set_company
  before_action :set_conversation

  def create
    # 1️⃣ Create the user's message
    @message = @conversation.messages.create!(
      content: params[:message][:content],
      role: "user"  # optional if you track role
    )

    # 2️⃣ Generate the assistant/system response
    response_content = generate_response(@message.content)

    @conversation.messages.create!(
      content: response_content,
      role: "assistant"
    )

    # 3️⃣ Redirect back to conversation
    redirect_to company_conversation_path(@company, @conversation)
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Failed to send message: #{e.message}"
    redirect_to company_conversation_path(@company, @conversation)
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
    puts @company.inspect
  end

  def set_conversation
    @conversation = @company.conversations.find(params[:id])
    puts @conversation.inspect
  end

  # Stub method for generating a response
  def generate_response(user_input)
    "Echo: #{user_input}"  # Replace with AI / bot logic if needed
  end
end


   #  response = FinancialResearchAgent.with(
    #   message: user_message.content,
    # ).research.generate_now
   