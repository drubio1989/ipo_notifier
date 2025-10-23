import consumer from "channels/consumer"

document.addEventListener("turbo:load", () => {
  const chatBox = document.getElementById("chat-box")
  const conversationData = document.getElementById("conversation-data")

  if (!chatBox || !conversationData) return

  const conversationId = conversationData.dataset.conversationId

  // Create a subscription to ConversationChannel
  consumer.subscriptions.create(
    { channel: "ConversationChannel", conversation_id: conversationId },
    {
      connected() {
        console.log(`✅ Connected to ConversationChannel ${conversationId}`)
      },

      disconnected() {
        console.log(`❌ Disconnected from ConversationChannel ${conversationId}`)
      },

      received(data) {
        // Handle incoming streamed message chunk
        appendMessageChunk(data)
      },
    }
  )

  // Helper function: appends incoming chunks to chat box
  function appendMessageChunk(data) {
    if (!data || !data.chunk) return

    // Find or create a streaming message block
    let assistantMessage = chatBox.querySelector(".message.role-assistant.streaming")

    // If no active assistant message block exists, create one
    if (!assistantMessage) {
      assistantMessage = document.createElement("div")
      assistantMessage.classList.add("message", "role-assistant", "streaming")

      assistantMessage.innerHTML = `
        <div class="message-meta">
          <span class="message-role font-semibold">Assistant:</span>
        </div>
        <div class="message-content text-gray-800 mt-1"></div>
      `

      chatBox.appendChild(assistantMessage)
    }

    // Append text incrementally to the content area
    const contentEl = assistantMessage.querySelector(".message-content")
    contentEl.innerHTML += data.chunk

    // Auto-scroll to the bottom
    chatBox.scrollTop = chatBox.scrollHeight
  }
})
