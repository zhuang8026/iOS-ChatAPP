import SwiftUI
import SocketIO

struct ContentViewDemo: View {
    @State private var messages: [(String, Bool)] = [] // 使用元組來存儲消息和它的來源
    @State private var messageText: String = ""
    @State private var isLoading: Bool = false // 判斷是否顯示加載動畫

    var body: some View {
        VStack {
//            List(messages, id: \.self) { message in
//                Text(message)
//            }
//            List {
//                ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
//                    Text(message)
//                }
//            }
//            if isLoading {
//                ProgressView("Loading...")
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else {
                List {
                    ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                        Text(message.0) // 元祖0:[string] 聊天內容
                        .padding()
                        //                       .background(message.1 ? Color.red.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        .listRowBackground(message.1 ? Color.red.opacity(0.2) : Color.white) // 元祖1: [bool] 判斷AI回覆
                    }
                }
                
//            }
            HStack {
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                Button(action: sendMessage) {
                    Text("Send")
                }
            }
            .padding()
        }
        .onAppear(perform: setupSocket)
    }

    // use url: http://54.65.71.9:5000
    // test url: http://localhost:3000
    private let manager = SocketManager(socketURL: URL(string: "http://54.65.71.9:5000")!, config: [.log(true), .compress])

    private var socket: SocketIOClient {
        return manager.defaultSocket
    }
    
    private func setupSocket() {
        // socket連線狀態
        socket.on(clientEvent: .connect) { data, ack in
            print("iOS client connected to the server")
//            socket.emit("ai_message", messageText)
        }

        // 用戶斷開連線
        socket.on(clientEvent: .disconnect) { data, ack in
            print("iOS client disconnected from the server")
        }
        
        // 伺服器發生錯誤
        socket.on(clientEvent: .error) { data, ack in
            print("Error: \(data)")
        }
        
        // 接收 server 端回傳數據
        socket.on("user_server_message") { data, ack in
            print("listening -> user_server_message")
            guard let firstData = data.first else {
                print("沒有收到數據")
                return
            }

            // 處理接收到的數據
            if let jsonObject = firstData as? [String: Any] {
                // 提取 "response" 字段
                if let response = jsonObject["response"] as? String {
                    DispatchQueue.main.async {
                        self.messages.append((response, false)) // false 表示來自 user_server_message
                    }
                    print("收到的 response: \(response)")
                } else {
                    print("數據格式不正確，'response' 欄位缺失或格式不正確")
                }
            } else {
                print("無法解析接收到的數據")
            }
        }
    
        // 接收 server 端回傳數據
        socket.on("ai_server_message") { data, ack in
            print("listening -> ai_server_message")
            guard let firstData = data.first else {
                print("沒有收到數據")
                return
            }

            // 處理接收到的數據
            if let jsonObject = firstData as? [String: Any] {
                // 提取 "response" 字段
                if let response = jsonObject["response"] as? String {
                    self.isLoading = true // 顯示加載動畫
//                    DispatchQueue.main.async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isLoading = false
                        self.messages.append((response, true)) // true 表示來自 ai_server_message
                    }
                    print("收到的 response: \(response)")
                } else {
                    print("數據格式不正確，'response' 欄位缺失或格式不正確")
                }
            } else {
                print("無法解析接收到的數據")
            }
        }
        
        socket.connect()
    }
    
    // 用戶發送訊息
    private func sendMessage() {
        socket.emit("user_message", messageText)
        socket.emit("ai_message", messageText)
        messageText = ""
        
        // 打印 messages 的內容
        print("Current messages: \(messages)")
        
    }
}

struct ContentViewDemo_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
