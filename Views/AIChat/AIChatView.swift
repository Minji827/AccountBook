import SwiftUI

struct AIChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "안녕하세요! 저는 당신의 AI 금융 비서입니다. 무엇을 도와드릴까요?", isUser: false)
    ]
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                            
                            if isTyping {
                                HStack {
                                    ProgressView()
                                        .padding(.leading)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                HStack {
                    TextField("메시지를 입력하세요...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isTyping)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(inputText.isEmpty || isTyping)
                }
                .padding()
            }
            .navigationTitle("AI 코칭")
        }
    }
    
    private func sendMessage() {
        let userText = inputText
        inputText = ""
        
        // Add user message
        let userMessage = ChatMessage(text: userText, isUser: true)
        messages.append(userMessage)
        
        isTyping = true
        
        Task {
            // Get AI response
            let responseText = await AIService.sendMessage(userText)
            
            await MainActor.run {
                let aiMessage = ChatMessage(text: responseText, isUser: false)
                messages.append(aiMessage)
                isTyping = false
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let date = Date()
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
            } else {
                HStack(alignment: .top) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                        .padding(.top, 8)
                    
                    Text(message.text)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                }
                Spacer()
            }
        }
    }
}

// Extension for partial corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct AIChatView_Previews: PreviewProvider {
    static var previews: some View {
        AIChatView()
    }
}
