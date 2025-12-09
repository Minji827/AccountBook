import SwiftUI

struct AIChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "안녕하세요! 오늘도 현명한 소비를 도와드릴게요. 무엇이 궁금하신가요? 😊", isUser: false)
    ]
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false

    let quickQuestions = [
        "💰 저축 목표 설정",
        "📊 지출 패턴 분석",
        "💵 환율 알림 설정"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
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

                // Quick questions
                VStack(alignment: .leading, spacing: 8) {
                    Text("빠른 질문")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickQuestions, id: \.self) { question in
                                Button(action: {
                                    sendQuickQuestion(question)
                                }) {
                                    Text(question)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(.primary)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray5)),
                    alignment: .top
                )

                // Input field
                HStack(spacing: 12) {
                    TextField("질문을 입력하세요...", text: $inputText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .disabled(isTyping)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(inputText.isEmpty ? .gray : .blue)
                    }
                    .disabled(inputText.isEmpty || isTyping)
                }
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray5)),
                    alignment: .top
                )
            }
            .navigationTitle("AI 코칭 🤖")
        }
    }

    private func sendQuickQuestion(_ question: String) {
        let userMessage = ChatMessage(text: question, isUser: true)
        messages.append(userMessage)

        isTyping = true

        Task {
            let responseText = await AIService.sendMessage(question)

            await MainActor.run {
                let aiMessage = ChatMessage(text: responseText, isUser: false)
                messages.append(aiMessage)
                isTyping = false
            }
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
