import SwiftUI
import SocketIO

struct MessageTT: Identifiable {
    var id = UUID() // Unique identifier
    var content: String
    var isSentByUser: Bool
    var time: String
    var date: String
    var status: Bool = false
}

extension Color {
    static let PrimaryColorTT = Color(red: 50.0 / 255.0, green: 53.0 / 255.0, blue: 98.0 / 255.0) // 深藍色 全域文字顏色
    static let ChatColorTT = Color(red: 40/255, green: 180/255, blue: 179/255)  // 綠松石色 聊天視窗
    static let GradientStartTT = Color(red: 9.0 / 255.0, green: 225.0 / 255.0, blue: 165.0 / 255.0) // 漸變色 深綠
    static let GradientEndTT = Color(red: 40.0 / 255.0, green: 180.0 / 255.0, blue: 179.0 / 255.0) // 漸變色 淺綠
    static let backgroundTT = Color(red: 238.0 / 255.0, green: 241.0 / 255.0, blue: 251.0 / 255.0) // 灰色
}

struct ContentViewDemo3: View {
    @State private var messages: [MessageTT] = [
//        Message(content: "您好，系統偵測到您8點到9點的用電比平時較為較大，請問您是否開啟/關閉了什麼電器？", isSentByUser: false, time: "12:30"),
    ]
    
    @State private var SEARCH_INFO: [MessageTT] = []
    
    @State private var FAQ_INFO: [MessageTT] = []

    @State private var messageText: String = "" // 用戶輸入框控制
    @State private var inquiryID: String = "" // token唯一碼
    @FocusState private var isInputFieldFocused: Bool // 鍵盤顯示控制
    @State private var isLoading: Bool = false // 判斷是否顯示加載動畫
    @State private var ActiveBtnName: String = "SEARCH" // 用電查詢是否被點擊

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // Chat history
                ScrollViewReader { proxy in
                   ScrollView {
                       VStack(alignment: .leading, spacing: 12) {
                           ForEach(self.messages.indices, id: \.self) { index in
                                let message = self.messages[index]
                                let showDate = index == 0 || self.messages[index - 1].date != message.date
                                if showDate {
                                Text(message.date)
                                  .font(.caption)
                                  .foregroundColor(.gray)
                                  .padding(.bottom, 5)
                                  .frame(maxWidth: .infinity)
                                  .multilineTextAlignment(.center)
                                }
                               ChatBubble_t(message: message.content, isSentByUser: message.isSentByUser, time: message.time, status: message.status)
                                   .id(message.id) // 設定每個訊息的ID
                           }
                           .padding(.top, 5)
                           .padding(.horizontal, 10) // 在外部容器中設置左右內邊距
                           
                            if isLoading {
                                ChatLoading_t().id("server_loading") // 为 ChatLoading 设置一个 ID
                            }
                       }
                       // [進入畫面觸發] 當視圖顯示時立即滾動到最後一個訊息
                       .onAppear {
                           if let lastMessage = self.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                       // [事件觸發] 滾動到最後一個訊息
                       .onChange(of: self.messages.count) { count, _ in
                            withAnimation {
                                if let lastMessage = self.messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                       .onChange(of: isLoading) { isLoading, _ in
                           // 当 isLoading 改变时，确保视图滚动到底部
                           print("isLoading: \(isLoading)")
                           withAnimation {
                               proxy.scrollTo("server_loading", anchor: .bottom)
                           }
                       }
                   }
                   .onTapGesture {
                       isInputFieldFocused = false // 點擊聊天區域時，聚焦輸入框
                   }
                }
                .padding(.top, 70) // 預留空間給 Header
                .padding(.bottom, 5) // 預留空間給 Header

                Spacer()

                // Buttons & send message
                VStack {
                    HStack {
                        // 用電查詢 按鈕
                        Button(action: {
                            // 這裡定義按鈕被點擊後要執行的動作
                            print("用電查詢 功能啟動!!!")
                            ActiveBtnName = "SEARCH" // 切換 用電查詢
                        }) {
                            Text("用電查詢")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(DefaultButtonStyle())
                        .frame( height: 40.0)
                        .background(ActiveBtnName == "SEARCH" ? AnyView(activeBtn) : AnyView(inactiveBtn))
//                        .foregroundColor(Color(white: 1.0))
                        .foregroundColor(ActiveBtnName == "SEARCH" ? .white : Color.ChatColorTT)
                        .cornerRadius(30.0)
                        .disabled(ActiveBtnName == "SEARCH")

                        // FAQ 按鈕
                        Button(action: {
                            // 這裡定義按鈕被點擊後要執行的動作
                            print("FAQ 功能啟動!!!")
                            ActiveBtnName = "FAQ" // 切換 FAQ
                        }) {
                            Text("FAQ")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(DefaultButtonStyle())
                        .frame( height: 40.0)
                        .background(ActiveBtnName == "FAQ" ? AnyView(activeBtn) : AnyView(inactiveBtn))
                        .foregroundColor(ActiveBtnName == "FAQ" ? .white : Color.ChatColorTT)
                        .cornerRadius(30.0)
                        .disabled(ActiveBtnName == "FAQ")
                        
                        // 異常推播 按鈕
//                        Button(action: {}) {
//                            Text("異常推播")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(DefaultButtonStyle())
//                        .frame( height: 40.0)
//                        .background(Color.background)
//                        .cornerRadius(30.0)
                    }
                    .padding(.horizontal, 10) // 左右內邊距 10 點
                    .padding(.top, 15) // 下邊距 0 點
                    .padding(.bottom, 0) // 下邊距 0 點

                    HStack {
                        TextEditor( text: $messageText)
                            .focused($isInputFieldFocused) // 綁定焦點狀態
                            .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)) // 內邊距
                            .background(Color.backgroundTT)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(Color.PrimaryColorTT) // 設置文字顏色為白色
                            .cornerRadius(30.0) // 圓角
                            .frame(minHeight: 50, maxHeight: .infinity) // 設置最小和最大高度
//                                .frame(height: geometry.size.height) // 設置高度為 GeometryReader 計算的高度
                            .onTapGesture {
                                isInputFieldFocused = true // 點擊時聚焦
                            }
                            .fixedSize(horizontal: false, vertical: true) // 使 TextEditor 在垂直方向上自適應
                        // 輸入訊息框
//                        TextField("輸入訊息", text: $messageText)
//                            .focused($isInputFieldFocused) // 綁定焦點狀態
//                            .padding() // 內邊距
//                            .background(Color.background)
//                            .foregroundColor(Color.PrimaryColorTT) // 設置文字顏色為白色
//                            .cornerRadius(30.0) // 圓角
//                            .onTapGesture {
//                                isInputFieldFocused = true // 點擊聊天區域時，聚焦輸入框
//                            }
                        // 發送訊息按鈕
                        Button(action: sendMessage) {
                            Image("send")
                                .resizable()
                                .frame(width: 35, height: 35)
                        }
                    }
                    .padding(10)
                }
                .background(Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 1.0))
            }

            // Header
            VStack {
                HStack {
                    Image("chat-bot")
                        .resizable()
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("AI 用電查詢 機器人")
                            .font(.headline)
                            .foregroundColor(Color.PrimaryColorTT) // 使用自訂顏色
                        Text("您的省電好幫手")
                            .font(.system(size: 14)) // 設置文字大小為 14
                            .foregroundColor(Color.PrimaryColorTT) // 使用自訂顏色
                    }
                    Spacer()
                    Image("out")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                .frame(height: 60.0)
                .padding(.horizontal, 10) // 設置左右內邊距為 10 點
                .background(Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 1.0))
                .cornerRadius(30.0)
            }
            .frame(maxWidth: .infinity) // 讓 Header 擴展到螢幕的寬度
            .padding(.horizontal, 10) // 設置左右內邊距為 10 點
            .position(x: UIScreen.main.bounds.width / 2, y: 30) // 固定在頂部
        }
        .background(Color(red: 222/255, green: 235/255, blue: 234/255))
        .onAppear(perform: setupSocket)
    }
    
    // has active button color
    private var activeBtn: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color.GradientStartTT, location: 0.0),
                Gradient.Stop(color: Color.GradientEndTT, location: 1.0)
            ],
            startPoint: .trailing,
            endPoint: .leading
        )
    }
    
    // no active button color
    private var inactiveBtn: some View {
        Color.backgroundTT
    }

    // 取得用戶token
    private func postSendUserID() {
        let user_id = "Asd@iii.org.tw"
        let data: [String: Any] = ["user_id": user_id]
        socket.emit("/power_inquiry/status", data)
        print("取得用戶token！")
    }

    // 用戶發送訊息
    private func postHistoryMessage() {
        let user_id = "Asd@iii.org.tw"
        let data: [String: Any] = [
            "user_id": user_id,
            "inquiry_id": self.inquiryID,
        ]
        print("postHistoryMessage \(data)")
        socket.emit("/history_message", data)
        // 打印 messages 的內容
        print("取得歷史資料！")
    }
    
    // 用戶發送訊息
    private func sendMessage() {
        // 檢查訊息是否為空
        guard !self.messageText.isEmpty else { return }
        
        // 創建一個新的訊息
        let newMessage = MessageTT(content: self.messageText, isSentByUser: true, time: getCurrentTime(), date: getCurrentDate())

        // 將新的訊息添加到陣列中
        self.messages.append(newMessage)

        let user_id = "Asd@iii.org.tw"
        let data: [String: Any] = [
            "user_id": user_id,
            "report_time": getCurrentFullTime(),
            "inquiry_id": self.inquiryID,
            "message": self.messageText
        ]
        
        self.isLoading = true // 顯示加載動畫
        socket.emit("/power_inquiry/user_message", data)
        
        // 清空輸入框
        self.messageText = ""
        
        // 發送後解除焦點
        isInputFieldFocused = false

        // 打印 messages 的內容
        print("Current messages: \(self.messages)")
    }
    
    // 獲取當前時間的函數 yyyy-MM-dd HH:mm:ss
    private func getCurrentFullTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 設定日期格式
        return dateFormatter.string(from: Date())
    }
    
    // 獲取當前時間的函數 yyyy-MM-dd
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 設定日期格式
        return dateFormatter.string(from: Date())
    }

    // 獲取當前時間的函數 HH:mm
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // 設定日期格式
        return dateFormatter.string(from: Date())
    }

    // 將日期時間字串轉換為指定格式的時間字串
    // ex: 2024-08-01 17:25:05  轉成 17:25
    private func convertDateToTimeString(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        
        // 設定原始日期時間字串的格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // 解析日期時間字串為 Date 對象
        if let date = dateFormatter.date(from: dateString) {
            // 設定轉換後的時間格式
            dateFormatter.dateFormat = "HH:mm"
            // 返回格式化後的時間字串
            return dateFormatter.string(from: date)
        }
        
        // 如果無法解析，返回 nil
        return nil
    }
    
    // 將日期時間字串轉換為指定格式的時間字串
    // ex: 2024-08-01 17:25:05  轉成 2024-08-01
    private func convertDateToDateString(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        
        // 設定原始日期時間字串的格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // 解析日期時間字串為 Date 對象
        if let date = dateFormatter.date(from: dateString) {
            // 設定轉換後的時間格式
            dateFormatter.dateFormat = "yyyy-MM-dd"
            // 返回格式化後的時間字串
            return dateFormatter.string(from: date)
        }
        
        // 如果無法解析，返回 nil
        return nil
    }
    
    // socket start
    // use url: http://54.65.71.9:5000
    // test url: http://localhost:3000
    private let manager = SocketManager(socketURL: URL(string: "http://54.65.71.9:5000")!, config: [.log(true), .compress])
    private var socket: SocketIOClient { return manager.defaultSocket }
    private func setupSocket() {
        // 定義一個標誌變數
        var hasServerError = false
        var hasUserDisconnect = false

        // socket連線狀態
        socket.on(clientEvent: .connect) { data, ack in
            print("iOS client connected to the server")
            self.postSendUserID() // [第一步] 進入聊天視窗取得用戶token
            
            hasServerError = false
            hasUserDisconnect = false
        }

        // 用戶斷開連線
        socket.on(clientEvent: .disconnect) { data, ack in
            print("[用戶斷開連線] iOS client disconnected from the server")
            
            // 如果標誌變數為 true，則不再添加新的錯誤訊息
            if hasUserDisconnect { return }
            
            // 創建一個新的訊息
            let newMessage = MessageTT(content: "用戶斷開連線", isSentByUser: false, time: getCurrentTime(), date: getCurrentDate(), status: true)

            // 將新的訊息添加到陣列中
            self.messages.append(newMessage)
            
            hasUserDisconnect = true // 更新標誌變數
            self.isLoading = false // 關閉加載動畫
        }
        
        // 伺服器發生錯誤
        socket.on(clientEvent: .error) { data, ack in
            print("[伺服器發生錯誤] Error: \(data)")

            // 如果標誌變數為 true，則不再添加新的錯誤訊息
            if hasServerError { return }
            
            // 創建一個新的訊息
            let newMessage = MessageTT(content: "伺服器發生錯誤", isSentByUser: false, time: getCurrentTime(), date: getCurrentDate(), status: true)

            // 將新的訊息添加到陣列中
            self.messages.append(newMessage)
            
            hasServerError = true // 更新標誌變數
            self.isLoading = false // 關閉加載動畫
        }

        // 監聽 server 端回傳數據
        // 取得 User information（get token）
        socket.on("/power_inquiry/status_response") { data, ack in
            print("listening -> '/power_inquiry/status_response'")
            print("[接收][取得 User information] \(data)")
            guard let firstData = data.first else {
                print("沒有收到數據")
                return
            }
             
            // 處理接收到的數據
            if let jsonObject = firstData as? [String: Any] {
                print("收到的 jsonObject: \(jsonObject)")
                // 提取 "response" 字段
                if let inquiry_id = jsonObject["inquiry_id"] as? String {
                    self.inquiryID = inquiry_id
                    print("收到的 inquiry_id: \(inquiry_id)")
                    self.postHistoryMessage() // [第二步] 進入聊天視窗取得用戶歷史資料
                } else {
                    print("數據格式不正確，'inquiry_id' 欄位缺失或格式不正確")
                }
            } else {
                print("無法解析接收到的數據")
            }
        }
    
        // 監聽 server 端回傳數據
        // 取得AI模型回話
        socket.on("/broadcast/inquiry_response") { data, ack in
            print("listening -> '/broadcast/inquiry_response'")
            print("[接收][AI模型回話] \(data)")
            guard let firstData = data.first else {
                print("沒有收到數據")
                return
            }

            // 處理接收到的數據
            if let jsonObject = firstData as? [String: Any] {
                // 提取 "response" 字段
                if let aiMessage = jsonObject["message"] as? String,
                   let reportTime = jsonObject["report_time"] as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // 創建一個新的訊息
                        let formattedTime = convertDateToTimeString(dateString: reportTime)
                        let formattedDate = convertDateToDateString(dateString: reportTime)
                        let newMessage = MessageTT(content: aiMessage, isSentByUser: false, time: formattedTime ?? "", date: formattedDate ?? "")
                        // 將新的訊息添加到陣列中
                        self.messages.append(newMessage)
                        // 關閉加載動畫
                        self.isLoading = false
                    }
                    print("收到的 ai_message: \(aiMessage)")
                } else {
                    print("數據格式不正確，'ai_message' 欄位缺失或格式不正確")
                }
            } else {
                print("無法解析接收到的數據")
            }
        }
        
        // 取得歷史資料
        socket.on("/history_message_response") { data, ack in
            print("listening -> '/history_message_response'")
            print("[接收][取得歷史資料] \(data)")
            self.messages = []
            // 將 data 轉換為陣列
            if let dataArray = data as? [[String: Any]] {
                // 處理每個字典
                for dictionary in dataArray {
                    // 提取 messages 陣列
                    if let messagesList = dictionary["messages"] as? [[String: Any]] {
                        // 處理每個消息對象
                        for messageObj in messagesList {
                            if let message = messageObj["message"] as? String,
                               let reportTime = messageObj["report_time"] as? String,
                               let type = messageObj["type"] as? String {
                                print("[消息]: \(message)")
                                print("[報告時間]: \(reportTime)")
                                print("[類型]: \(type)")
                                
                                // 使用 convertDateToTimeString 方法來格式化 reportTime
                                let formattedTime = convertDateToTimeString(dateString: reportTime) // HH:MM
                                let formattedDate = convertDateToDateString(dateString: reportTime) // yyyy-MM-dd
                                let newMessage = MessageTT(content: message, isSentByUser: !(type == "AI"), time: formattedTime ?? "", date: formattedDate ?? "")

                                // 將新的訊息添加到陣列中
                                self.messages.append(newMessage)

                                // 關閉加載動畫
                                self.isLoading = false
                            } else {
                                print("消息對象格式不正確")
                            }
                        }
                    } else {
                        print("找不到 messages 鍵或其格式不正確")
                    }
                }
            } else {
                print("資料格式不正確")
            }
        }
        
        // socket 連接
        socket.connect()
    }
}

// 聊天視窗
struct ChatBubble_t: View {
    var message: String
    var isSentByUser: Bool
    var time: String
    var status: Bool

    var body: some View {
        HStack {
            if !isSentByUser {
                // 機器人對話框（左邊）
                HStack(alignment: .bottom) {
                    Text(message)
                        .padding()
                        .background(status ?
                                    Color(red: 1.0, green: 108.0 / 255.0, blue: 108.0 / 255.0) :
                                    Color(red: 40/255, green: 180/255, blue: 179/255))
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
                // 用戶對話框（右邊）
                HStack(alignment: .bottom) {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                    Text(message)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .foregroundColor(Color.PrimaryColorTT) // 設置文字顏色為白色
                    
                }
            }
        }
    }
}

// 加載動畫視窗
struct ChatLoading_t: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .opacity(self.isAnimating ? 0.3 : 1)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(0.2 * Double(index)), value: isAnimating
                    )
            }
        }
        .frame(width: 100, height: 40)
        .background(Color(red: 40/255, green: 180/255, blue: 179/255))
        .cornerRadius(10)
        .padding(.leading, 10)
        .onAppear {
            self.isAnimating = true
        }
    }
}

struct ContentViewDemo3_ContentView: View {
    var body: some View {
        ContentViewDemo3()
    }
}
