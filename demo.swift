import SwiftUI
import SocketIO

struct ChatView: View {
    @State private var messages: [(String, Bool)] = [("您好，系統偵測到您8點到9點的用電比平時較為較大，請問您是否開啟/關閉了什麼電器？", false),
         ("我也不清楚，我在家都在睡覺", true),
         ("好的，我會檢查一下。", false),
         ("謝謝！", true)
    ] // 使用元組來存儲消息和它的來源
    @State private var messageText: String = ""
    @State private var inquiryID: String = ""
    @State private var isLoading: Bool = false // 判斷是否顯示加載動畫
    @FocusState private var isInputFieldFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // Chat history
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages, id: \.0) { (message, isSentByUser) in
                            ChatBubble(message: message, isSentByUser: isSentByUser, time: "12:30")
                        }
                        .padding(.top, 5) // 設置上邊距為 10 點
                    }
                }
                .padding(.top, 70) // 預留空間給 Header

                Spacer()
                
                // Buttons
                HStack {
                    Button(action: {}) {
                        Text("用電查詢")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DefaultButtonStyle())
                    
                    Button(action: {}) {
                        Text("FAQ")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DefaultButtonStyle())
                    
                    Button(action: {}) {
                        Text("異常推播")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DefaultButtonStyle())
                }
                .padding()
                
                HStack {
                    TextField("Enter message", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputFieldFocused) // 綁定焦點狀態
                        .frame(minHeight: 30)
                    Button(action: sendMessage) {
                        Text("Send")
                    }
                }
                .padding()
                .onTapGesture {
                    isInputFieldFocused = true // 點擊聊天區域時，聚焦輸入框
                }
            }

            // Header
            HStack {
                Image("chat-bot")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("AI XXXXX 機器人")
                    .font(.headline)
                Spacer()
                Image("out")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            .frame(height: 60.0)
            .padding(.horizontal, 10) // 設置左右內邊距為 10 點
            .background(Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 1.0))
            .cornerRadius(30.0)
            .position(x: UIScreen.main.bounds.width / 2, y: 30) // 固定在頂部
        }
        .background(Color(red: 222/255, green: 235/255, blue: 234/255))
    }
    
    // 用戶發送訊息
    private func sendMessage() {
        isInputFieldFocused = false // 可選：解除焦點
//        let user_id = "Asd@iii.org.tw"
//        let data: [String: Any] = [
//            "user_id": user_id,
//            "report_time": "2024-07-30 07:59:00",
//            "inquiry_id": self.inquiryID,
//            "message": self.messageText
//        ]
//
//        self.isLoading = true // 顯示加載動畫
//        socket.emit("/power_inquiry/user_message", data)
//        self.messages.append((self.messageText, false)) // true 表示來自 ai_server_message
////        socket.emit("user_message", messageText)
////        socket.emit("ai_message", messageText)
//        messageText = ""
//
//        // 打印 messages 的內容
//        print("Current messages: \(messages)")
    }
}

struct ChatBubble: View {
    var message: String
    var isSentByUser: Bool
    var time: String
    
    var body: some View {
        HStack {
            if !isSentByUser {
                HStack(alignment: .bottom) {
                    Text(message)
                        .padding()
                        .background(Color(red: 40/255, green: 180/255, blue: 179/255))
                        .cornerRadius(10)
                        .foregroundColor(.white) // 設置文字顏色為白色
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                }
                Spacer()
            } else {
                Spacer()
                HStack(alignment: .bottom) {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                    Text(message)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                    
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        ChatView()
    }
}
