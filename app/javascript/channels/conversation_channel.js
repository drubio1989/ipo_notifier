import consumer from "channels/consumer"
document.addEventListener("DOMContentLoaded", () => {
  const chatBox = document.getElementById("chat-box")
  let inputBox = document.getElementById("user_question")
  const conversationId =  document.getElementById("conversation-data").dataset.conversationId

  // ActionCable subscription
  consumer.subscriptions.create({channel: "ConversationChannel", conversation_id: conversationId },
    {
      initialized() {
        this.appendMessage = this.appendMessage.bind(this);
        this.handleInputSubmit = this.handleInputSubmit.bind(this);
      }, 
      
      connected() {
      
        this.install()
      },
      
      disconnected() {
        this.uninstall()
      },

      received(data) {
        this.appendMessage(data)
      },

      appendMessage(data) {
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

        const contentDiv = msgDiv.querySelector(".message-content")
        contentDiv.innerHTML += data.delta
        chatBox.scrollTop = chatBox.scrollHeight

        // Clear input if message was a response to the user
        inputBox.value = ""
      },
      
      install() {
        const form = document.getElementById("new_message")
        if (form) {
          form.addEventListener("submit", this.handleInputSubmit)
        }
      },
      
      uninstall() {
        const form = document.getElementById("question-form")
        if (form) {
          form.removeEventListener("submit", this.handleInputSubmit)
        }
      },

      handleInputSubmit(event) {
        event.preventDefault()
        const content = inputBox.value.trim()
        if (content === "") return

        // Send user message to server
        this.perform("send_message", { content: content })

        // Optionally, append user message to chat immediately
        const userDiv = document.createElement("div")
        userDiv.className = "message role-user bg-blue-50 p-3 rounded-lg space-y-1"
        userDiv.innerHTML = `<div class="message-content">${content}</div>`
        chatBox.appendChild(userDiv)
        chatBox.scrollTop = chatBox.scrollHeight

        // Clear input
        console.log(inputBox)
        inputBox.value = ""
      }
    }
  )
})


