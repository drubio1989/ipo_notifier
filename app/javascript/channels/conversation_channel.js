import consumer from "channels/consumer"

document.addEventListener("DOMContentLoaded", () => {
  const chatBox = document.getElementById("chat-box")
  const conversationData = document.getElementById("conversation-data")
  const conversationId = conversationData.dataset.conversationId

  // ActionCable subscription
  consumer.subscriptions.create(
    { channel: "ConversationChannel", conversation_id: conversationId },
    {
      received(data) {
        // Find existing message or create new
        let msgDiv = document.querySelector(`[data-message-id='${data.message_id}']`)
        if (!msgDiv) {
          msgDiv = document.createElement("div")
          msgDiv.dataset.messageId = data.message_id
          msgDiv.className = "message role-assistant bg-gray-50 p-3 rounded-lg space-y-1"

          // Add message meta
          const metaDiv = document.createElement("div")
          metaDiv.className = "message-meta"
          metaDiv.innerHTML = `
            <span class="message-role font-semibold">Assistant:</span>
            <time class="message-time text-xs text-gray-400">${new Date().toLocaleString()}</time>
          `
          msgDiv.appendChild(metaDiv)

          // Add message content container
          const contentDiv = document.createElement("div")
          contentDiv.className = "message-content"
          msgDiv.appendChild(contentDiv)

          chatBox.appendChild(msgDiv)
        }

        // Append delta to content div
        const contentDiv = msgDiv.querySelector(".message-content")
        contentDiv.innerHTML += data.delta
       

        // Scroll to bottom
        chatBox.scrollTop = chatBox.scrollHeight
      }
    }
  )


})
